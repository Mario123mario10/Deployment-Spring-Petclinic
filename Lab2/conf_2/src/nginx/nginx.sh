#!/bin/bash

BACKEND_IP=$1
BACKEND_PORT_1=$2
BACKEND_PORT_1=$3
BACKEND_PORT_1=$4
NGINX_PORT=$5

apt-get update
apt-get upgrade -y
apt install nginx -y
echo "upstream backend {
    server $BACKEND_IP:$BACKEND_PORT_1;
    server $BACKEND_IP:$BACKEND_PORT_2;
    server $BACKEND_IP:$BACKEND_PORT_3;
}

server {
    listen      $NGINX_PORT;

    location /petclinic/api {
        proxy_pass http://backend;
    }
}
" > ./nginx.conf
mv ./nginx.conf /etc/nginx/sites-available/default

service nginx restart
