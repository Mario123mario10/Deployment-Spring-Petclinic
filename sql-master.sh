#!/bin/sh

DB_USER=admin
DB_PASSWORD=admin

CONFIG_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"
INIT_DATABASE="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/initDB.sql"
POPULATE_DATABASE="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/populateDB.sql"

cd ~/

sudo apt update
sudo apt upgrade -y

sudo apt install mysql-server -y
sudo apt install wget -y

echo "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';" >> init.sql
echo "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%' WITH GRANT OPTION;" >> init.sql

wget $INIT_DATABASE
wget $POPULATE_DATABASE

sudo sed -i "s/127.0.0.1/0.0.0.0/g" $CONFIG_FILE
sudo sed -i "s/.*server-id.*/server-id = 1/" $CONFIG_FILE
sudo sed -i "s/.*log_bin.*/log_bin = \\/var\\/log\\/mysql\\/mysql-bi.log/" $CONFIG_FILE
sudo sed -i "1s/^/USE petclinic;\n/" ./populateDB.sql

cat ./init.sql | sudo mysql -f
cat ./initDB.sql | sudo mysql -f
cat ./populateDB.sql | sudo mysql -f

sudo mysql -v -e "FLUSH PRIVILEGES;"
sudo service mysql restart
