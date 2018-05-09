#!/bin/bash

#Ningx environment variables
envsubst '\$APP_ENV \$APP_DEBUG \$HTTPS_FORCE' < /usr/local/nginx/nginx.tmpl > /usr/local/nginx/conf/nginx.conf

#enable https redicection and pagespeed in prod mode
if [[ "$HTTPS_FORCE" = "off" ]]; then
    cat "" > /usr/local/nginx/https_force.conf
fi

if [[ "$APP_ENV" = "dev" ]]; then
    cat "" > /usr/local/nginx/pagespeed.conf
fi

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