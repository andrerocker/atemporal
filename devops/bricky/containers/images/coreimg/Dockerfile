FROM ubuntu:14.04
MAINTAINER andrerocker 0.1

RUN apt-get install --no-install-recommends -y --force-yes software-properties-common
RUN apt-add-repository -y ppa:brightbox/ruby-ng

RUN apt-get update
RUN apt-get install --no-install-recommends -y --force-yes \
	ruby2.2 libpq5 libxml2 libxslt1.1 zlib1g rsync

RUN gem install bundler
RUN echo 'export PATH=$PATH:/usr/local/bin' >> /etc/profile
