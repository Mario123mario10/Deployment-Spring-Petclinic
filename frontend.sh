#!/bin/sh

NGINX_IP="$1"

cd ~/

sudo apt update
sudo apt upgrade -y
sudo apt install npm -y

sudo npm cache clean -f
sudo npm install -g n
sudo n stable
hash -r

sudo npm uninstall -g angular-cli @angular/cli
sudo npm install -g @angular/cli@latest

git clone https://github.com/spring-petclinic/spring-petclinic-angular.git
cd spring-petclinic-angular/
sed -i "s/localhost/$NGINX_IP:8081/g" src/environments/environment.ts src/environments/environment.prod.ts

npm install --save-dev @angular/cli@latest --force
rm package-lock.json
npm install --force

echo N | ng analytics off
echo Y | sudo ng serve --host 0.0.0.0 --port 80 &