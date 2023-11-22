#!/bin/bash

NGINX_PORT=$1
BACKEND_1=$2
BACKEND_2=$3
BACKEND_3=$4

sudo su
sudo apt update -y
sudo apt install -y nginx

cd ~

cat > loadbalancer.conf << EOL
upstream backend {
    server 10.0.0.5:$BACKEND_1;
    server 10.0.0.5:$BACKEND_2;
    server 10.0.0.5:$BACKEND_3;
}

server {
    listen      $NGINX_PORT;

    location /petclinic/api {
        proxy_pass http://backend;
    }
}
EOL

sudo mv loadbalancer.conf /etc/nginx/conf.d/loadbalancer.conf

sudo nginx -s reload

