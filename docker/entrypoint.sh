#!/bin/bash

#Ningx environment variables
envsubst '\$APP_ENV \$APP_DEBUG \$HTTPS_FORCE' < /usr/local/nginx/nginx.tmpl > /usr/local/nginx/conf/nginx.conf

#enable https redicection and pagespeed in prod mode
if [[ "$HTTPS_FORCE" = "off" ]]; then
    cat "" > /usr/local/nginx/https_force.conf
fi

#configure dev or prod php settings
CONFFILE_FPM="/etc/php/7.1/fpm/conf.d/50-custom.ini"
[ -f "$CONFFILE_FPM" ] && rm "$CONFFILE_FPM"

if [[ "$APP_ENV" = "dev" ]]; then
    cat "" > /usr/local/nginx/pagespeed.conf
    ln -s /etc/php/7.1/php-dev.ini /etc/php/7.1/fpm/conf.d/50-custom.ini
else
    ln -s /etc/php/7.1/php-prod.ini /etc/php/7.1/fpm/conf.d/50-custom.ini
fi

#Add same configuration to php-cli
cp /etc/php/7.1/fpm/conf.d/50-custom.ini /etc/php/7.1/cli/conf.d/50-custom.ini

#Causes the shell to exit if any subcommand or pipeline returns a non-zero status.
set -e

if [[ "$1" = "supervisord" ]]; then
    rm -rf var/cache/*
    if [[ "$APP_ENV" = "prod" ]]; then
        bin/console cache:clear --env=prod --no-warmup
        bin/console cache:warmup --env=prod
    fi
    chown -R www-data:www-data var
fi

exec "$@"