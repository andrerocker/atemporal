## andrerocker, atemporal

A prosposta dessa PoC é resolver o desafio passado por email, o enunciado propunha a implementação
de um sistema executor de processos duradouros baseados em um container docker agendados para executar
em um horario previamente expecificado em conjunto a um payload baseado em variaveis de ambiente.

*Uma condição pre estabelecida é a de que o processo sempre deve ser executado em uma nova instancia
EC2, e que ao termino do processo tambem deve ser desprovionada.*

## preparando seu workspace

Antes de iniciar você vai precisar instalar algumas coisas e configurar outras, vamos la:

```
- realize o clone do projeto :p (git clone https://github.com/andrerocker/atemporal.git)
- Você deve possuir uma chave publica RSA em ~/.ssh/id_rsa.pub (ssh-keygen -t rsa)
- Criar um arquivo chamado .credentials, com duas linhas: chave e token da aws
- Criar um arquivo chamado .docker-username, com uma linha, com seu conta do dockerhub
- Certifique-se de que tem instalado as seguintes ferramentas: 
	- local para deploy: make, docker, docker-compose, terraform 
	- local para desenvolvimento: rvm (ruby 2.2.2), bundle, postgresql
- Usuario local deve ter acesso ao daemon docker (usermod -a -G docker <seu usuario>
- Certifique-se de estar logado no dockerhub 
- As credenciais da AWS devem possuir as permissões necessaria para criar os recursos
- Nesse momento ainda não é possivel fazer deploys concorrentes na mesma conta
```

Apos terminar as configurações acima você ja vai estar apto a executar um deploy completo da aplicação, para isso basta executar um simples: ```make application-fullstack-deploy``` paciencia, pois primeira vez demorar vai demorar um pouco, pois vamos buildar todas as imagens necessarias, vamos buildar a aplicação, envia-la ao registry, provisionar a infraestrutura (o banco de dados é que mais demora) e ao termino da execução você vai ter um output parecido com o seguinte:

```
Outputs:

  database     = atemporal-rds.c776vkpzyr9e.us-west-1.rds.amazonaws.com
  loadbalancer = atemporal-1388666537.us-west-1.elb.amazonaws.com
  server       = ec2-184-169-192-107.us-west-1.compute.amazonaws.com,
  		 	ec2-54-215-55-160.us-west-1.compute.amazonaws.com, 
  		 	ec2-54-219-16-146.us-west-1.compute.amazonaws.com
```

*apartir daqui você ja pode conectar no hostname do loadbalancer e executar suas chamadas a API, note que existe a possibilidade dos serviços ainda estarem inicializando então pode ser legal fazer um request no /*

*Os builds consecutivos vão ser extremamente mais rapidos, pois no caminho eu crio alguns caches, inclusive um especifico para as gems utilizadas no projeto.*

## endpoints da aplicação

Conforme solicitado a aplicação possui alguns endpoints chave, e acabei tomando a liberdade me colacar alguma coisa
a mais, segue abaixo:

```

```


## a implementação

Pensei em diferentes modelos de arquitetura e tecnologias para resolver esse problema, no entanto esses
meu ultimos dias foram muito corridos e então acabei optando por tecnologias que tenho mais familiaridade,
ou que trariam uma solução menos complicada (pelo menos no meu ponto de vista)

**Terraform:** Como solução para automatizar o provisionamento da infraestrutura optei por utilizar o Terraform,
foi a minha primeira experiencia com a ferramenta, apesar de algumas "limitações" funcionou conforme o esperado.

*para realizar esse provisionamento acabei escrevendo duas tasks make para auxiliar na atividade, vou ilustrar
os codigos abaixo*

*setup da infra:* 

```make
servers-bootstrap:
	cd devops/terraform; terraform apply \
		-var "public_key=$(shell cat ~/.ssh/id_rsa.pub)" \
		-var "access_key=$(shell head -1 .credentials)" \
		-var "secret_key=$(shell tail -1 .credentials)" \
		-var "docker_username=$(shell cat .docker-username)" \
		-var "cluster_discovery=$(shell curl -s http://discovery.etcd.io/new)"
```

*shutdown infra:* 

```make
servers-terminate:
	cd devops/terraform; terraform destroy -force \
		-var "public_key=$(shell cat ~/.ssh/id_rsa.pub)" \
		-var "access_key=$(shell head -1 .credentials)" \
		-var "secret_key=$(shell tail -1 .credentials)" \
		-var "docker_username=1337" \
		-var "cluster_discovery=1337"
```

**Topologia:** 1 load balancer, 3 instancias ec2 abaixo do balancer, 1 servidor de banco de dados (postgresql), 1 grupo de segurança permitindo acesso apenas a porta 80 e 22 nos servidores principais, 1 grupo de segurança com tudo liberado para ser utilizado na instancia de jobs a serem executados, segue abaixo o desenho exportado pelo proprio terraform.

![Terraform](https://raw.githubusercontent.com/andrerocker/atemporal/master/devops/others/graph.png)

**Servidores:** Inicialmente estava pensando em fazer um aplicação empacotada para debian e utilizar um Ubuntu 14.04,
ou até mesmo um Debian Wheezy, no entanto como havia o trabalho de realizar o deploy do processo
a ser "schedulado" como container acabei voltando atras na ideia do pacote debian e optei por empacotar
o projeto em um container. Partindo dai nenhuma escolha seria mais natural do que utilizar o CoreOS como 
sistema base para rodar toda a aplicação.

**CoreOS:** No meu ponto de vista foi uma decisão totalmente acertada porque o cloud-config.yml traz tudo que 
preciso para realizar o deploy do projeto da forma mais simples e sofisticada, no primeiro momento fiz um setup para utilizar fleet e etcd, no segundo momento optei por desligar esses recursos e utilizar unicamente o systemd. 

CoreOS tambem se mostrou uma excelente escolha para ser a plataforma de execução das tasks pois novamente o cloud-config.yml trouxe de graça certas facilidades que eu outro cenario seria chato de implementar, por exemplo o suporte a "rederizar" arquivos de configuração inline com encoding em base64.

*Abaixo está um exemplo da solução utilizada para resolver o problema da injeção de variaveis de ambiente
no processo a ser schedulado, com essa tecnica eu bloquei de forma simples e eficaz qualquer tentiva de injeção
de codigo arbitrario que possa quebrar meu fluxo de provisionamento, pra ver o cloud-config completo utilizado no worker [clique aqui](https://github.com/andrerocker/atemporal/blob/master/webapp/config/worker-cloud-config.yml)*

```yaml
#cloud-config

write_files:
  - path: /etc/atemporal-environments-worker
    encoding: base64
    content: |
      QU5EUkU9Zm9kYW8K

```

**Implementação:** Acabei realizando a implementação da API utilizando Ruby, Rails e um processador de jobs assincronos simples que permitisse o schedule de operações de forma "segura", vou escrever mais detalhes sobre a implementação em topicos individuais abaixo:

*API:* Optei por utilizar o Rails por uma possivel simplicidade, e por estar mais familizado com suas gems e ecosistema, nesse ponto, itens importantes que considero que devem ser citados é que utilizei uma gem para maquinas de estado, uma pra criar representers dos objetos a serem exportados pela API, e postgresql como banco de dados.

*Scheduler:* Para resolver o problema de scheduler, em um primeiro momento optei por utilizar o Sidekiq, no entanto sempre considei o Redis uma escolha errada pra ser backend de filas, sendo assim dei rollback na ideia e optei por utilizar o velho Delayed Jobs com backend no banco de dados ja provisionado pela aplicação.

*Http:* Quando a minha ideia ainda era usar pacotes, por algum motivo estava pensando em servir a aplicação com um proxy reverso para o puma utilizando um nginx, no entanto como a aplicação é exclusivamente uma API acredito que não faz sentido algum ter um "atravesador" no meio do request, então no novo desenho utilizando container optei por deixar o puma de cara para o ELB na porta 80.

*Estrutura do projeto:* Voce vai notar que a estrutura do projeto esta dividida basicamente em dois diretorios: webapp e devops, optei por esse modelo pra definir claramente a finalidade de cada codebase no projeto ja que agora temos a possibilidade de ter a infraestrutura como codigo, isso é uma coisa simples mas pode trazer um ganho muito grande quando passamos a ter um numero maior de aplicações com esse perfil utilizando tecnologias totalmente diferentes para cada finalidade. 

*Make*: Uma coisa que você vai notar tambem é que estou utilizando o make como porta de entrada pra execução das principais atividades da aplicação (com exceção de start e stop de processos locais para desenvolvimento), como estamos usando um diversidade grande de ferramentas na aplicação fica complicado decorar cada comando, e até mesmo impraticavel executalos passando um monte de parametro na mão, sendo assim o make foi uma solução simples e pratica pra resolver o "problema"

**Pipeline de Deploy:** O projeto deve ser empacotado em um container pronto para a execução, e deve depender unica e exclusivamente de apenas algumas variaveis de ambiente, sendo assim o pipeline pra deploy acabou sendo o seguinte: build local, publish por registry e start do processo, vou descrever cada um desses passos abaixo:

*Optei por ter basicamente 3 images docker do projeto, uma com a finalidade exclusiva de fazer build, com ferramentas proprias para compilação e libs expecificas para tal. Outra, totalmente exuta exclusivamente para runtime, e uma base com coisas em comum para as duas primeiras imagens*

```make
package-bootstrap:
        docker build -t atemporal/coreimg devops/bricky/containers/images/coreimg
        docker build -t atemporal/builder devops/bricky/containers/images/builder
```

*build:* Nesse passo utilizo o docker-compose para realizar o build do projeto com a imagem de build gerada durante o processo  ```package-bootstrap``` (ilustrado acima), o que o docker compose faz é basicamente montar o diretorio atual dentro do container de build, vendorizar a aplicação ```bundle install --deployment``` e dispobiliza-la como um arquivo tar em um diretorio tambem montado dentro do container, ao termino desse processo realizo o build da imagem de runtime com o ultimo codigo da aplicação realizado.

*para visualizar o script de build e o yml utilizado pelo docker-compose nesse processo de uma olhada [aqui](https://github.com/andrerocker/atemporal/blob/master/devops/bricky/atemporal-builder.yml) e [aqui](https://github.com/andrerocker/atemporal/blob/master/devops/bricky/containers/scripts/builder)*

*a primeira execução pode ser terrivelmente lenta, no entanto as proximas execuções seram extremamente rapidas,
pois no caminho vou construindo uma serie de caches.*

```make
package-builder:
        docker-compose -p atemporal -f devops/bricky/atemporal-builder.yml \
        	run builder /scripts/builder
        docker build -t atemporal/runtime devops/bricky/containers/images/runtime
```

*publish:* Uma vez feito o build da aplicação então publicamos o novo container para o docker-registry, no caso da PoC o docker registry publico, conforme a task abaixo:

*note que nesse momento eu não pensei em versionamento*

```make
package-registry:
        docker tag -f atemporal/runtime $(shell cat .docker-username)/atemporal
        docker push $(shell cat .docker-username)/atemporal
```

*deploy:* Feito tudo isso agora é possivel realizar o deploy da aplicação, pra isso basta executar a task ```application-deploy``` que por padrão já chama as tasks ```package-builder```, ```package-registry```

```make
application-deploy: package-builder package-registry
	devops/deploy
```

*fullstack deploy:* Tambem é possivel realizar um deploy partindo totalmente do zero, provisionando toda a infraestrutura necessaria para o projeto, então executar os builder necessarios, publicação e deploy, para isso execute a task ```application-fullstack-deploy```

*as informações passadas acima são apenas para demostrar o que pensei para realizar o processo, vou escrever de forma mais objetiva e simples como fazer uma publicação basica da aplicações nos passos a seguir*

## Desenvolvimento:

Para realizar modificações sera necessario realizar os seguintes passos:

```
- rvm install 2.2.2
- gem install bundler
- bundle install
- rake db:create db:migrate
- rails s
```

Ao termino do desenvolvimento é possivel testar suas modificações com o container de runtime de forma extrammente simples, pra isso será necessario executar um novo build(```make package-builder```) e então executar um ```package-runtime```, o codigo para essa task make pode ser visto abaixo:

```make
package-runtime:
docker-compose -p atemporal -f devops/bricky/atemporal-runtime.yml run \
-e AWS_ACCESS_KEY=$(shell head -1 .credentials) \
-e AWS_SECRET_ACCESS_KEY=$(shell tail -1 .credentials) \
-e AWS_REGION=us-west-1 -e AWS_IMAGE_ID=ami-4df91b09 -e AWS_INSTANCE_TYPE=t1.micro \
-e AWS_KEY_NAME=atemporal -e AWS_SECURITY_GROUP=atemporal-worker \
--service-ports runtime /start
```
