#!/bin/bash

# Aktualizacja systemu i instalacja NGINX
sudo apt update
sudo apt install -y nginx

# Zatrzymywanie serwera NGINX na czas konfiguracji
sudo systemctl stop nginx

# Tworzenie nowego pliku konfiguracyjnego dla NGINX
cat <<EOT | sudo tee /etc/nginx/nginx.conf

# Global settings
user nginx;
worker_processes auto;
pid /run/nginx.pid;
include /usr/share/nginx/modules/*.conf;

# Events section
events {
    worker_connections 1024;
}

http {
    upstream backend_servers {
        server 10.0.0.5:9961;
        server 10.0.0.5:9962;
    }

    server {
        listen 8081;

        location / {
            proxy_pass http://backend_servers;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOT

# Restart serwera NGINX aby zastosować nową konfigurację
sudo systemctl start nginx