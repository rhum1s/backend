# Installation de PostgreSQL / PostGIS
# Testé avec Ubuntu 16.04.4 LTS 
# Testé avec postgis-2.4 | postgis-2.4
# Pour connaitre votre version : lsb_release -a
# FIXME: Pour l'instant seulement Ubuntu 16.04.4 xenial
# La machine doit avoir un dossier /mnt/sdb/postgres_data
# Le rôle PostgreSQL qui sera crée doit correspondre à un user de la machine
# Exit on error
set -e

# Going Home
cd ~

# Checking for pg data folder
if [ -d "/mnt/sdb/postgres_data" ]
then
    echo
else
    echo "ERROR: A directory /mnt/sdb/postgres_data must exist"
    exit
fi

# Warning User
read -p """
ATTENTION - WARNING -
Va supprimer toutes les données dans
/mnt/sdb/postgres_data
/var/lib/postgresql/9.6

et les fichiers de configuration dans 
/etc/postgresql/9.6

Souhaitez vous vraiment continuer? (y/n):
# """ -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Goin on"
else
    exit
fi

# Asking for user values
read -p "Quel port affecter à PostgreSQL?" pgport

echo "- Adding apt repostory ..."
# FIXME: Repository depends on versions. Works only for xenial
sudo touch /etc/apt/sources.list.d/pgdg.list
echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' | sudo tee -a /etc/apt/sources.list.d/pgdg.list 
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add
sudo apt-get update
echo "... done."

echo "- Instgalling PostgreSQL package ..."
sudo apt-get install postgresql-9.6
sudo -u postgres psql --version
echo "... done."

echo "- Creating new super user and modifying postgres pwd ..."
# FIXME: Will fail if user already exists !
echo "$lgn password:"
sudo -u $lgn createuser --pwprompt
echo "postgres password:"
sudo -u postgres psql -U postgres -d postgres -c "\password"
echo "... done."

# Moving data folder
echo "- Moving data folder ..."
sudo systemctl stop postgresql
sudo systemctl status postgresql
sudo rm -r /mnt/sdb/postgres_data/*
sudo rsync -av /var/lib/postgresql /mnt/sdb/postgres_data
sudo mv /var/lib/postgresql/9.6/main /var/lib/postgresql/9.6/main.bak
if [ -f "/etc/postgresql/9.6/main/postgresql.conf.orig" ]
then
	echo "Already exists"
ielse
	sudo cp /etc/postgresql/9.6/main/postgresql.conf /etc/postgresql/9.6/main/postgresql.conf.orig
sudo sed -i "s/data_directory = '\/var\/lib\/postgresql\/9.6\/main'/data_directory = '\/mnt\/sdb\/postgres_data\/postgresql\/9.6\/main'/" /etc/postgresql/9.6/main/postgresql.conf
sudo systemctl start postgresql
sudo systemctl status postgresql
psql -U rhum -d postgres -c "SHOW data_directory;"
sudo rm -Rf /var/lib/postgresql/9.6/main.bak
echo "... done."

echo "- Shutting server down ..."
sudo systemctl stop postgresql
sudo systemctl status postgresql
echo "... done."

echo "- Changing Port ..."
sudo sed -i "s/port = 5432/port = "$pgport"/" /etc/postgresql/9.6/main/postgresql.conf
echo "... done."

echo "- Listen worldwide ..."
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/9.6/main/postgresql.conf
if [ -f "/etc/postgresql/9.6/main/pg_hba.conf.orig" ]
then
        echo "pg_hba orig file already exists"
else
        sudo cp /etc/postgresql/9.6/main/pg_hba.conf /etc/postgresql/9.6/main/pg_hba.conf.orig
fi
echo 'host    all     all         0.0.0.0/0           md5' | sudo tee -a /etc/postgresql/9.6/main/pg_hba.conf
echo "... done."

echo "- Starting server ..."
sudo systemctl start postgresql
sudo systemctl status postgresql
echo "... done."

echo "- Installing PostGIS + pgrouting..."
# FIXME: Repository depends on versions. Works only for xenial
sudo apt-get install postgresql-9.6-postgis-2.4
sudo apt-get install postgresql-9.6-pgrouting
sudo apt-get install --no-install-recommends postgis-gui
libgtk2.0-bin
# TODO have shp2pgsql not only gui
echo "... done."





echo "- Creating PostGIS templates ..."
psql -U rhum -d postgres -c "CREATE DATABASE template_postgis;"
psql -U rhum -d template_postgis -c "CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;"
psql -U rhum -d template_postgis -c "CREATE SCHEMA topology;"
psql -U rhum -d template_postgis -c "CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;"
echo "... end."

echo "- Restarting server ..."
sudo systemctl restart postgresql
sudo systemctl status postgresql
echo "... done."

