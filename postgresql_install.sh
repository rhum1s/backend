# Installation de PostgreSQL / PostGIS
# Testé avec Ubuntu 16.04.4 LTS 
# Testé avec PostgreSQL v TODO | PostGIS v TODO
# Pour connaitre votre version : lsb_release -a
# La machine doit avoir un dossier /mnt/sdb/postgres_data

# Exit on error
set -e

# Going Home
cd ~

# Warning ! Will delete all
# read -p """
# ATTENTION -
# Va supprimer toutes les données dans
# TODO
#
# Souhaitez vous vraiment continuer? (y/n):
# """ -n 1 -r
# echo
# if [[ $REPLY =~ ^[Yy]$ ]]
# then
#     echo "Lets'go"
# else
#     exit
# fi

# Checking for pg data folder 
if [ -d "/mnt/sdb/postgres_data" ]
then 
    echo 
else
    echo "ERROR: A directory /mnt/sdb/postgres_data must exist"
    exit
fi

# Ask user for global vars
read -p 'PostgreSQL su login: ' lgn
read -sp 'PostgreSQL su password: ' pwd
read -p 'SSH port: ' port


