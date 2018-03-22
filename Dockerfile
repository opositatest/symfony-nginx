FROM ubuntu:16.04

ARG APP_ENVIRONMENT
ARG APP_ENV="dev"
ARG APP_DEBUG
ARG HTTPS_FORCE

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TERM="xterm" \
    DEBIAN_FRONTEND="noninteractive" \
    COMPOSER_ALLOW_SUPERUSER=1 \
    APP_ENV="$APP_ENV" \
    APP_DEBUG="$APP_DEBUG" \
    HTTPS_FORCE="$HTTPS_FORCE" \
    TIMEZONE="$TIMEZONE"

COPY . /config

RUN apt-get update -q && \
    apt-get install --no-install-recommends -qy software-properties-common language-pack-en-base && \
    export LC_ALL=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get update -q && \
    apt-get install --no-install-recommends -qy \
        ca-certificates \
        curl \
        nano \
        mysql-client \
        php7.1 \
        php7.1-bcmath \
        php7.1-common \
        php7.1-curl \
        php7.1-dom \
        php7.1-fpm \
        php7.1-gd \
        php7.1-iconv \
        php7.1-intl \
        php7.1-json \
        php7.1-mbstring \
        php7.1-mcrypt \
        php7.1-mysql \
        php7.1-opcache \
        php7.1-pdo \
        php7.1-phar \
        php7.1-xml \
        php7.1-zip \
        php-apcu \
        php-uuid \
        redis-server \
        supervisor \
        git \
        tzdata \
        wget \
        sed \
        #pagespeed packages
        build-essential \
        zlib1g-dev \
        libpcre3 \
        libpcre3-dev \
        unzip uuid-dev \
        openssh-client \
        gettext-base  \
        && \

    cp /usr/share/zoneinfo/Europe/Madrid /etc/localtime && echo $TIMEZONE > /etc/timezone && \

    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \

    #Pagespeed Install
    curl -f -L -sS https://ngxpagespeed.com/install > pagespeed.sh && \
    chmod +x pagespeed.sh && \
    #Remove sudo command for pagespeed script, we have running this script like root, whe dont
    #need use sudo. Sudo in docker container have secury issues.
    sed -e s/sudo//g -i pagespeed.sh && \
    ./pagespeed.sh  --nginx-version latest && \
    rm pagespeed.sh && \

    #Remove build dependencies
    apt-get remove -y build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  && \

    #Configure environment
    cp /config/docker/entrypoint.sh /usr/local/bin/entrypoint.sh && \

    #PHP configuration
    cp /config/docker/php/php*.tmpl /etc/php/7.1/ && \
    rm -rf /etc/php/7.1/fpm/pool.d/www.conf && \
    mv /config/docker/php/pool.conf /etc/php/7.1/fpm/pool.d/www.conf && \
    mkdir /run/php && \

    #Nginx configuration
    rm -rf /usr/local/nginx/conf/nginx.conf && \
    cp /config/docker/nginx/nginx.tmpl /usr/local/nginx/nginx.tmpl && \
    mkdir -p /usr/local/nginx/conf.d/ && \
    mv /config/docker/nginx/pagespeed.conf /usr/local/nginx/ && \
    mv /config/docker/nginx/redirects.conf /usr/local/nginx/ && \

    #pagespeed cache
    mkdir -p /var/ngx_pagespeed_cache && \
    chown www-data:www-data /var/ngx_pagespeed_cache && \

    #supervisor config
    mv /config/docker/nginx/supervisord.conf /etc/supervisor/conf.d/ && \

    #Remove configuration files
    rm -rf /config/docker 

EXPOSE 80

WORKDIR /app

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
