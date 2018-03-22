#Symfony + Nginx + Pagespeed container

Dockerfile inspired in https://github.com/EnMarche/en-marche.fr/blob/develop/Dockerfile whit some modifications.

Tested on symfony 3.4

Services:
---

* nginx
* pagespeed
* php 7.1


Fetures:
---

* This image run php-fpm with Nginx in the same container with unix socket.
* This image uses the same entrypoint for all symfony environments. Build it one time and run in multiple environments. 
  You should implement a similar web/index.php in your proyect:

```
....
$kernel = new AppKernel(getenv('APP_ENV'), getenv('APP_DEBUG'));
$request = Request::createFromGlobals();
....
```

# Parameters
---


$APP_ENV
    
    Determine the symfony environment dev, prod, test....
    
$APP_DEBUG

    Determine if application is in debug mode:
        0 disabled
        1 enabled

$HTTPS_FORCE
    on and off
    
    If value is on, proxy pass https protocol to backend so it will return pages and assets with https protocol

$TIMEZONE

    Proyect timezone 

Build
---

To build this image:

> docker build -t opositatest/symfony-nginx:latest --build-arg APP_ENV=dev --build-arg APP_DEBUG=1 --build-arg HTTPS_FORCE=off --build-arg TIMEZONE="Europe/Madrid" .  



