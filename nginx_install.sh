# Install nginx latest official version (apt) extras package
# Testé avec Ubuntu 16.04.4 LTS
# FIXME: Package depends on ubuntu versions

# Exit on error
set -e

# Going home
cd ~

echo "- Adding nginx repository ..."
sudo touch /etc/apt/sources.list.d/nginx.list
echo "
deb http://nginx.org/packages/ubuntu/ xenial nginx
deb-src http://nginx.org/packages/ubuntu/ xenial nginx
" | sudo tee -a /etc/apt/sources.list.d/nginx.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
sudo apt-get update 
echo "... done." 

echo "- Installing nginx ..."
sudo apt-get install nginx-common
sudo apt-get install nginx-extras
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
echo "... done."

sudo systemctl status nginx
