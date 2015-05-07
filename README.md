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

## estrutura do projeto

Voce vai notar que a estrutura do projeto esta dividida basicamente em dois diretorios:
	- webapp: codigo do projeto em si
	- devops: scripts, e codigo relacionados ao deploy e infraestrutura
