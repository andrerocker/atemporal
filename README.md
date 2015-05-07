## andrerocker, atemporal

A prosposta dessa PoC é resolver o desafio passado por email, o enunciado propunha a implementação
de um sistema executor de processos duradouros baseados em um container docker, agendados para executar
em um horario previamente expecificado em conjunto a um payload baseado em variaveis de ambiente.

Uma condição pre estabelecida é a de que o processo sempre deve ser executado em uma nova instancia
EC2, que ao termino do processo tambem deve ser desprovionada.

## a implementação

Pensei em diferentes modelos de arquitetura e tecnologias para resolver esse problema, no entanto esses
meu ultimos dias foram muito corridos e então acabei optando por tecnologias que tenho mais familiaridade,
ou que trariam uma solução menos complicada (pelo menos no meu ponto de vista)

Terraform: Como solução para automatizar o provisionamento da infraestrutura optei por utilizar o Terraform,
foi a minha primeira experiencia com a ferramenta, apesar de algumas "limitações" funcionou conforme o esperado
e sem muito esforço.

Servidores: Inicialmente estava pensando em fazer um aplicação empacotada para debian e utilizar um Ubuntu 14.04,
ou até mesmo um Debian Wheezy como server, no entanto como havia o trabalho de realizar o deploy do processo
a ser "schedulado" como container acabei voltando atras na ideia do pacote debian e optei por empacotar
o projeto em um container. Partindo dai nenhuma escolha seria mais natural do que utilizar o CoreOS como 
sistema base para rodar toda a aplicação.

Tecnologias utilizadas: Ruby e Rails, Docker, Docker Compose, PostgreSQL, Terraform, Docker Hub, Make,
AWS, CoreOS.

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

## estrutura do projeto

Voce vai notar que a estrutura do projeto esta dividida basicamente em dois diretorios:
	- webapp: codigo do projeto em si
	- devops: scripts, e codigo relacionados ao deploy e infraestrutura
