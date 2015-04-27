#!/usr/bin/sudo bash

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
apt-get install --no-install-recommends -y --force-yes \
  apt-transport-https \
  ca-certificates \
  software-properties-common

apt-add-repository -y ppa:brightbox/ruby-ng
echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' > /etc/apt/sources.list.d/passenger.list
echo 'deb [trusted=yes] https://4DSoHeowovJgJ2LvG-p4@apt.fury.io/deploy42/ /' > /etc/apt/sources.list.d/andrerocker.list

apt-get update
apt-get install --no-install-recommends -y --force-yes atemporal

gem install bundler
echo 'export PATH=$PATH:/usr/local/bin' >> /etc/profile

service nginx restart
