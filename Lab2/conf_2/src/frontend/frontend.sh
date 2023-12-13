#!/bin/bash

FRONT_PORT=$1
API_IP=$2
API_PORT=$3

apt-get update -y
apt-get upgrade -y
apt-get -y install curl git

curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh
bash /tmp/nodesource_setup.sh
apt-get -y install nodejs

mkdir -p /petclinic/frontend
cd /petclinic/frontend

git clone https://github.com/spring-petclinic/spring-petclinic-angular.git
cd spring-petclinic-angular/

rm package-lock.json
npm install --dev @angular/cli@latest -y
# npm install --save-dev @angular/cli@latest --force
npm install --force

sed -i "s/localhost/$API_IP/g" src/environments/environment.ts src/environments/environment.prod.ts
sed -i "s/9966/$API_PORT/g" src/environments/environment.ts src/environments/environment.prod.ts

source <(ng completion script)
ng analytics off

npx ng build
npm install angular-http-server --force
npx angular-http-server --path ./dist -p "$FRONT_PORT" &
