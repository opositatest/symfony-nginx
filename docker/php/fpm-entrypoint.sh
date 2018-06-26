#!/usr/bin/env bash

# We need parse php-fpm logs to avoid problems with php-fpm logs when is inside docker container
# Its a php-fpm bug:
# https://github.com/docker-library/php/issues/207

/usr/sbin/php-fpm7.1 -F -O 2>&1 | sed -u 's,.*: \"\(.*\)$,\1,'| sed -u 's,"$,,' 1>&1