# Install nginx latest official repository version and extras package
# Testé avec Ubuntu 16.04.4 LTS
# FIXME: Package depends on ubuntu versions
# Files will go in /mnt/sdb/nginx_data folder. Must exist.
# TIXME: Pas finalisé. Ne pas lancer en l'état.

# Exit on error
set -e

# Must stay in backend dir to access files
# cd ~

# TODO Check /mnt/sdb/nginx_data folder

# TODO: Ask for [USER]

echo "- Adding nginx repository ..."
sudo touch /etc/apt/sources.list.d/nginx.list
echo "
deb http://nginx.org/packages/ubuntu/ xenial nginx
deb-src http://nginx.org/packages/ubuntu/ xenial nginx
" | sudo tee /etc/apt/sources.list.d/nginx.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
sudo apt-get update 
echo "... done." 

echo "- Installing nginx ..."
sudo apt-get install nginx-common
sudo apt-get install nginx-extras
if [ -f "/etc/nginx/nginx.conf.orig" ] ; then
	echo ""
else
	sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
fi
sudo chown -R rhum:root /etc/nginx
echo "... done."

echo "- Installing php7-fpm ..."
sudo apt-get install php7.0 php7.0-fpm
sudo apt-get install php7.0-curl
sudo apt-get install php7.0-mbstring
sudo systemctl restart php7.0-fpm
sudo systemctl status php7.0-fpm
sudo systemctl restart nginx
if [ -f "/etc/php/7.0/fpm/pool.d/www.conf.orig" ] ; then
	echo ""
else
	sudo cp /etc/php/7.0/fpm/pool.d/www.conf /etc/php/7.0/fpm/pool.d/www.conf.orig
fi
sudo sed -i -e "s/;listen.mode = 0660/listen.mode = 0660/g" /etc/php/7.0/fpm/pool.d/www.conf
if [ -f "/var/run/php/php7.0-fpm.sock" ] ; then
	sudo rm /var/run/php/php7.0-fpm.sock
fi
sudo service nginx restart
sudo service php7.0-fpm restart
echo "... done."

echo "- Create main page ..."
sudo touch /mnt/sdb/nginx_data/index.php
echo "<?php echo 'Working';?>" | sudo tee /mnt/sdb/nginx_data/index.php
echo "... done."

sudo rm /etc/nginx/sites-enabled/default
sudo cp data/sites_enabled_main /etc/nginx/sites-enabled/sites_enabled_main
sudo chown -R [USER]:root /etc/nginx/sites-enabled/sites_enabled_main

# User owner
# FIXME: Ask for user
sudo chown -R [USER]:root /mnt/sdb/nginx_data

echo "- Creating default config file ..."
sudo nginx -t
echo "... done."

# Restart nginx
sudo systemctl restart nginx
sudo systemctl status nginx

# Installing Composer
cd ~
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php
composer

