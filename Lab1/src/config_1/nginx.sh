#!/bin/bash

BACKEDN_IP=$1
PORT1=$2
PORT2=$3
PORT3=$4
FRONT_IP=$5
FRONT_PORT=$6



sudo apt-get update -y
sudo apt install nginx -y


# Tworzenie nowego pliku konfiguracyjnego dla NGINX
cat <<EOT | sudo tee /etc/nginx/nginx.conf
http {
    upstream backend_servers {
        server $BACKEDN_IP:$PORT1;
        server $BACKEDN_IP:$PORT2;
        server $BACKEDN_IP:$PORT3;
    }

    server {
        listen $FRONT_PORT;

        location /petclinic/api {
            proxy_pass http://backend_servers;
        }
    }
}
EOT

# Restart serwera NGINX aby zastosować nową konfigurację
sudo nginx -s reload
