#!/bin/bash

BACKEDN_IP=$1
PORT1=$2
PORT2=$3
PORT3=$4
FRONT_IP=$5
FRONT_PORT=$6



# Aktualizacja systemu i instalacja NGINX
sudo apt update
sudo apt install -y nginx

# Zatrzymywanie serwera NGINX na czas konfiguracji
sudo systemctl stop nginx

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

        location / {
            proxy_pass http://$FRONT_IP:$FRONT_PORT;
            # proxy_set_header Host \$host;
            # proxy_set_header X-Real-IP \$remote_addr;
            # proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            # proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOT

# Restart serwera NGINX aby zastosować nową konfigurację
sudo systemctl start nginx
