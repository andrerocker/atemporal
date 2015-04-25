FROM ubuntu:14.04
MAINTAINER Platform Team 0.2

RUN apt-get update
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
RUN apt-get install --no-install-recommends -y --force-yes apt-transport-https ca-certificates
RUN echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' > /etc/apt/sources.list.d/passenger.list

RUN apt-get install --no-install-recommends -y --force-yes software-properties-common
RUN apt-add-repository -y ppa:brightbox/ruby-ng

RUN apt-get update
RUN apt-get install --no-install-recommends -y --force-yes ruby2.2
RUN gem install bundler
RUN echo 'export PATH=$PATH:/usr/local/bin' >> /etc/profile
