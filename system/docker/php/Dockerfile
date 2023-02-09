FROM php:fpm-alpine

ENV SRC_PATH=/var/www/html

ENV TZ Europe/Madrid

RUN apk update --update
RUN apk add -U tzdata
RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime

RUN apk update; \
    apk upgrade;
RUN apk --no-cache add \
    gettext \
    gettext-dev \
    icu-dev \
    jpeg-dev \
    libpng-dev
    
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-configure gettext &&\
    docker-php-ext-install gettext &&\
    docker-php-ext-configure intl &&\
    docker-php-ext-install intl
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN apk fix && \
    apk --no-cache --update add git git-lfs gpg less openssh zlib-dev libpng-dev libzip libzip-dev && \
    git lfs install

RUN docker-php-ext-install gd zip
RUN docker-php-ext-configure gd --with-jpeg &&\
	docker-php-ext-install -j$(nproc) gd &&\
	docker-php-ext-install exif