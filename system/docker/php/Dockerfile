FROM php:fpm-alpine

ENV SRC_PATH=/var/www/html

ENV TZ Europe/Madrid

RUN apk update --update
RUN apk add -U tzdata
RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime

RUN apk update; \
    apk upgrade;
RUN docker-php-ext-install pdo_mysql