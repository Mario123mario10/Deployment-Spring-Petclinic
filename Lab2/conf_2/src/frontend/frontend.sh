#!/bin/bash

FRONTEND_PORT="$1"
BACKEND_IP="$2"
BACKEND_PORT="$3"

mkdir -p /petclinic/frontend
cd /petclinic/frontend

apt update
apt upgrade -y
apt install npm -y

npm cache clean -f
npm install -g n
n stable
hash -r

npm uninstall -g angular-cli @angular/cli
npm install -g @angular/cli@latest

git clone https://github.com/spring-petclinic/spring-petclinic-angular.git
cd spring-petclinic-angular/
sed -i "s/localhost/$BACKEND_IP/g" src/environments/environment.ts src/environments/environment.prod.ts
sed -i "s/9966/$BACKEND_PORT/g" src/environments/environment.ts src/environments/environment.prod.ts

npm install --save-dev @angular/cli@latest --force
rm package-lock.json
npm install --force

echo N | ng analytics off
echo Y | ng serve --host 0.0.0.0 --port $FRONTEND_PORT &
