#!/bin/bash

DB_PORT=$1

apt-get update -y
apt-get upgrade -y

apt-get -y install mariadb-server wget

echo "[mysqld]" >> /etc/mysql/mariadb.conf.d/90-server.cnf
echo "bind-address = 0.0.0.0" >> /etc/mysql/mariadb.conf.d/90-server.cnf
echo "port = $DB_PORT" >> /etc/mysql/mariadb.conf.d/90-server.cnf

service mariadb restart

mkdir -p /petclinic/db
cd /petclinic/db

wget https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/initDB.sql
wget https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/populateDB.sql
sed -i "1s/^/USE petclinic;\n/" ./populateDB.sql

mysql -e "CREATE USER 'pc'@'%' IDENTIFIED BY 'petclinic'; GRANT ALL PRIVILEGES ON *.* TO 'pc'@'%' WITH GRANT OPTION;"
cat initDB.sql | mysql -f
cat populateDB.sql | mysql -f

service mariadb restart
