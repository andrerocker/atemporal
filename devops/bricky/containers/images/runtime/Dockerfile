FROM atemporal/coreimg
MAINTAINER andrerocker 0.1

ADD scripts /
ADD package /opt

RUN mkdir -p /var/www
RUN tar -xzf /opt/application.tar -C /var/www
RUN mkdir -p /var/www/atemporal/log && touch /var/www/atemporal/log/production.log

RUN chown -R www-data. /var/www/atemporal
