FROM httpd:alpine

ENV TZ Europe/Madrid

RUN apk update --update
RUN apk add -U tzdata
RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime

RUN sed -i '/LoadModule rewrite_module/s/^#//g' /usr/local/apache2/conf/httpd.conf