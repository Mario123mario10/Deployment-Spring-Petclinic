#!/bin/bash


API_PORT_WRITE=$1
DB_IP_MASTER=$2
DB_PORT_MASTER=$3

apt-get -y update
apt-get -y upgrade
apt-get -y install openjdk-17-jdk git mariadb-client

mkdir -p /petclinic/backend_write
cd /petclinic/backend_write

git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd ./spring-petclinic-rest

master_db_url="jdbc:mysql:\/\/${DB_IP_MASTER}:${DB_PORT_MASTER}\/petclinic?useUnicode=true&allowSourceDownConnections=true"

sed -i "s/hsqldb,//g" src/main/resources/application.properties src/test/resources/application.properties
sed -i "s/9966/${API_PORT_WRITE}/g" src/main/resources/application.properties

sed -i "38s/^/spring.datasource.url = ${master_db_url}\n/" src/main/resources/application.properties
sed -i "39s/^/spring.datasource.username=pc\n/" src/main/resources/application.properties
sed -i "40s/^/spring.datasource.password=petclinic\n/" src/main/resources/application.properties
sed -i "41s/^/spring.datasource.driver-class-name=com.mysql.jdbc.Driver\n/" src/main/resources/application.properties
sed -i "42s/^/spring.jpa.database=MYSQL\n/" src/main/resources/application.properties
sed -i "43s/^/spring.jpa.database-platform=org.hibernate.dialect.MySQLDialect\n/" src/main/resources/application.properties
sed -i "44s/^/spring.jpa.hibernate.ddl-auto=none\n/" src/main/resources/application.properties

while [ "$(mysqladmin ping -u pc --password=petclinic  -h ${DB_IP_MASTER} -P ${DB_PORT_MASTER})" != "mysqld is alive" ]; do sleep 2; done; 

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/
./mvnw spring-boot:run &
