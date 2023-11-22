#!/bin/bash

# Aktualizacja systemu i instalacja NGINX
sudo apt update
sudo apt install -y nginx

# Zatrzymywanie serwera NGINX na czas konfiguracji
sudo systemctl stop nginx

# Tworzenie nowego pliku konfiguracyjnego dla NGINX
cat <<EOT | sudo tee /etc/nginx/nginx.conf
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




http {
    upstream backend-master {
        server master-backend-ip:port;
    }

    upstream backend-slave {
        server slave-backend-ip:port;
    }

    server {
        listen 80;

        location / {
            if ($request_method = GET) {
                proxy_pass http://backend-slave;
            }

            if ($request_method ~* "(POST|PUT|DELETE)") {
                proxy_pass http://backend-master;
            }

            # Common proxy settings
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}