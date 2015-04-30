FROM locaweb/wheezy
MAINTAINER andrerocker 0.1

RUN apt-get update && apt-get install -y --force-yes nginx
ENTRYPOINT /usr/sbin/nginx -g "daemon off; error_log /dev/stdout;"
