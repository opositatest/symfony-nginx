#!/bin/bash

#Ningx environment variables
envsubst '\$APP_ENV \$APP_DEBUG \$HTTPS_FORCE' < /usr/local/nginx/nginx.tmpl > /usr/local/nginx/conf/nginx.conf

#php environment variables
envsubst '\$TIMEZONE' < /etc/php/7.1/php-${APP_ENV}.ini.tmpl > /etc/php/7.1/cli/conf.d/50-setting.ini
envsubst '\$TIMEZONE' < /etc/php/7.1/php-${APP_ENV}.ini > /etc/php/7.1/fpm/conf.d/50-setting.ini

#Causes the shell to exit if any subcommand or pipeline returns a non-zero status.
set -e

if [[ "$1" = "supervisord" ]]; then
    rm -rf var/cache/*
    bin/console cache:clear --env=prod --no-warmup
    bin/console cache:warmup --env=prod
    chown -R www-data:www-data var
fi

exec "$@"