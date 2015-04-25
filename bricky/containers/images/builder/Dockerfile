FROM ubuntu:14.04
MAINTAINER andrerocker 0.1

RUN apt-get update
RUN apt-get install --no-install-recommends -y --force-yes software-properties-common
RUN apt-add-repository -y ppa:brightbox/ruby-ng

RUN apt-get update
RUN apt-get install -y --force-yes ruby2.2
RUN apt-get install -y --force-yes debhelper ruby2.2-dev libxml2-dev libxslt-dev zlib1g-dev libpq-dev
