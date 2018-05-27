# Première configuration d'un machine Ubuntu
# Testé avec Ubuntu 16.04.4 LTS 
# Pour connaitre votre version : lsb_release -a
# Must be run as root
# Warning, root user will not be able to connect using ssh anymore
# Warning: Must be launched in root backend/ directory

# Exit on error
set -e

# Ask user for global vars
read -p 'Global username: ' glgn
read -p 'SSH port: ' port
read -p 'GITHub username: ' git_lgn
read -p 'GITHub mail adress: ' git_mail

echo "- Check for updates ..."
apt-get update
apt-get upgrade
echo "  ... done."

echo "- Modify ssh port ..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
sed -i -e "s/Port 22/Port $port/g" /etc/ssh/sshd_config
sed -i -e "s/# Port 22/Port $port/g" /etc/ssh/sshd_config
sed -i -e "s/#Port 22/Port $port/g" /etc/ssh/sshd_config
echo "  ... done."

echo "- Modify root mdp ..."
passwd root
echo "  ... done."

echo "- Creating new super user ..."
adduser $glgn
usermod -aG sudo $glgn
echo "  ... done."

echo "- Installing unzip ..."
apt-get install unzip
echo "  ... done."

echo "- Giving rights to /opt ..."
chown $glgn:root -R /opt
echo "  ... done."

echo "- Desactivating ssh root access ..."
sed -i -e "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
sed -i -e "s/#PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
sed -i -e "s/# PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
echo "  ... done."

echo "- Configuring git ..."
git config --global user.name "${git_lgn}"
git config --global user.email "${git_mail}"
git config core.fileMode false
echo "  ... done."

echo "- Installing fail2ban"
echo "  TODO !"
echo "  ... done."

echo "- Installing screen and config files"
sudo apt-get install screen
cp data/.screen* ~/
echo "  ... done."

echo "- Restarting SSH, you must then connect with new user"
/etc/init.d/ssh restart
echo "  ... done."
