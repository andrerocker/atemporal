## andrerocker, atemporal

A prosposta dessa PoC é resolver o desafio passado por email, o enunciado propunha a implementação
de um sistema executor de processos duradouros baseados em um container docker agendados para executar
em um horario previamente expecificado em conjunto a um payload baseado em variaveis de ambiente.

*Uma condição pre estabelecida é a de que o processo sempre deve ser executado em uma nova instancia
EC2, e que ao termino do processo tambem deve ser desprovionada.*

## a implementação

Pensei em diferentes modelos de arquitetura e tecnologias para resolver esse problema, no entanto esses
meu ultimos dias foram muito corridos e então acabei optando por tecnologias que tenho mais familiaridade,
ou que trariam uma solução menos complicada (pelo menos no meu ponto de vista)

**Terraform:** Como solução para automatizar o provisionamento da infraestrutura optei por utilizar o Terraform,
foi a minha primeira experiencia com a ferramenta, apesar de algumas "limitações" funcionou conforme o esperado.

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

Tecnologias utilizadas: Ruby e Rails, Docker, Docker Compose, PostgreSQL, Terraform, Docker Hub, Make,
AWS, CoreOS.

*Estrutura do projeto:* Voce vai notar que a estrutura do projeto esta dividida basicamente em dois diretorios: webapp e devops, optei por esse modelo pra definir claramente a finalidade de cada codebase no projeto ja que agora temos a possibilidade de ter a infraestrutura como codigo, isso é uma coisa simples mas pode trazer um ganho muito grande quando passamos a ter um numero maior de aplicações com esse perfil utilizando tecnologias totalmente diferentes para cada finalidade. 

## preparando seu workspace

Antes de iniciar você vai precisar instalar algumas coisas e configurar outras, vamos la:

```
- Você deve possuir uma chave publica RSA em ~/.ssh/id_rsa.pub
- Criar um arquivo chamado .credentials, com duas linhas: chave e token da aws
- Criar um arquivo chamado .docker-username, com uma linha, com seu conta do dockerhub
- Certifique-se de que tem instalado as seguintes ferramentas: 
	- local para desenvolvimento: rvm (ruby 2.2.2), postgresql
	- local para deploy: make, docker, docker-compose, terraform 
```
Como o projeto acabou usando uma serie de comandos e combinações diferentes para executar direferentes atividades
acabei optando por utilizar o make como porta de entreda para execução das principais operações do projeto.

Como por exemplo: Construir imagens base para build e execução local, processo para build e execução, processo de upload de container para o docker registry, processo para start e stop de infraestrutura, e deploy.
