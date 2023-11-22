#!/bin/bash

INIT_DATABASE="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/initDB.sql"
POPULATE_DATABASE="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/populateDB.sql"
MY_SQL_CONFIG="/etc/mysql/mysql.conf.d/mysqld.cnf"

sudo apt-get update
sudo apt install mysql-server -y
sudo apt install wget -y

wget $INIT_DATABASE
wget $POPULATE_DATABASE

sed -i "s/127.0.0.1/0.0.0.0/" $MY_SQL_CONFIG
sed -i "s/localhost/0.0.0.0/" ./initDB.sql

sudo mysql -e "CREATE USER 'pc'@'%' IDENTIFIED BY 'pc';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'pc'@'%' WITH GRANT OPTION;"
sudo mysql -e "FLUSH PRIVILEGES;"
cat ./populateDB.sql >> ./initDB.sql
sudo mysql < ./initDB.sql

sudo service mysql restart

sudo mysql -v -e "UNLOCK TABLES;"
echo "MySQL server is installed and configured"
