# Zainstaluj MySQL
sudo apt-get update
sudo apt-get install mysql-server -y

# Skonfiguruj MySQL jako master
sudo sed -i '/\[mysqld\]/a server-id=1\nlog_bin=mysql-bin\nbinlog_do_db=petclinic' /etc/mysql/mysql.conf.d/mysqld.cnf

# Restart MySQL
sudo systemctl restart mysql

# Ustawienia w MySQL
mysql -u root -p -e "
CREATE USER 'azureuser'@'%' IDENTIFIED BY 'azurepass';
GRANT REPLICATION SLAVE ON . TO 'repl_user'@'%';
FLUSH PRIVILEGES;
CREATE DATABASE petclinic;
"