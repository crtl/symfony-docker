FROM php:7.4-fpm AS app_php

ARG WORKDIR=/var/www
ARG PHP_VERSION=7.4
ARG NGINX_VERSION=1.21.0


RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install system packages
RUN apt-get update && apt-get install -y apt-transport-https && apt-get install -y git curl zip unzip libicu-dev

# Cleanup apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install php extensions
RUN docker-php-ext-install pdo_mysql intl iconv bcmath

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Switch workin directory
WORKDIR ${WORKDIR}

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
COPY composer.json composer.lock symfony.lock ./
RUN set -eux; \
	composer install --prefer-dist --no-autoloader --no-scripts  --no-progress --no-suggest; \
	composer clear-cache

RUN set -eux \
	&& mkdir -p var/cache var/log \
	&& composer dump-autoload --classmap-authoritative

# Create var volume
VOLUME ${WORKDIR}/var

RUN chmod -R 1000 ${WORKDIR}/var

# Copy entrypoint script
COPY .docker/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]

CMD ["php-fpm"]


FROM nginx:1.21.0-alpine AS app_nginx

COPY .docker/nginx/default.conf /etc/nginx/conf.d/

WORKDIR /app/public
