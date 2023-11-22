#!/bin/bash

BACKEND_PORT=$1
DB_ADDRESS=10.0.0.8

sudo apt update -y
sudo apt install -y openjdk-11-jdk

cd ~

git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest


sed -i "s/spring.datasource.password=petclinic/spring.datasource.password=pc/" src/main/resources/application-mysql.properties
sed -i "s/localhost/$DB_ADDRESS/" src/main/resources/application-mysql.properties
sed -i "s/hsqldb/mysql/" src/main/resources/application.properties
sed -i "s/9966/$BACKEND_PORT/g" src/main/resources/application.properties src/test/resources/application.properties

sudo ./mvnw spring-boot:run > ~/spring.log &

