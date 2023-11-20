# Zainstaluj MySQL
sudo apt-get update
sudo apt-get install mysql-server -y

# Skonfiguruj MySQL jako slave
sudo sed -i '/\[mysqld\]/a server-id=2\nrelay-log=mysql-relay-bin\nreplicate_do_db=petclinic' /etc/mysql/mysql.conf.d/mysqld.cnf

# Restart MySQL
sudo systemctl restart mysql

# Ustawienia w MySQL
mysql -u root -p -e "
CHANGE MASTER TO
MASTER_HOST='10.0.0.6',
MASTER_USER='azureuser',
MASTER_PASSWORD='azurepass',
MASTER_LOG_FILE='mysql-bin.000001',
MASTER_LOG_POS=  107;
START SLAVE;
"