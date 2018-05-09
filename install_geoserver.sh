# Install and configure Geoserver 2.13.0 
# Testé avec Ubuntu 16.04.4 LTS
# Avoir installé Oracle java JRE 8
# Avoir installé Tomcat /opt/tomcat
# TODO: Delete native jai and image IO files in geoserver ??

# Exit on error
set -e
cd ~

echo "- Removing /opt/tomcat/webapps/geoserver* ..."
if [ -f "/opt/tomcat/webapps/geoserver.war" ]; then rm /opt/tomcat/webapps/geoserver.war; fi
if [ -d "/opt/tomcat/webapps/geoserver" ]; then rm -r /opt/tomcat/webapps/geoserver; fi
echo "  ... done."

echo "Installing Geoserver ..."
if [ -d "~/geoserverTmp" ]; then rm -r ~/geoserverTmp; fi
mkdir ~/geoserverTmp
cd ~/geoserverTmp
wget -O geoserver.zip https://sourceforge.net/projects/geoserver/files/GeoServer/2.13.0/geoserver-2.13.0-war.zip/download 
unzip geoserver.zip
mv geoserver.war /opt/tomcat/webapps/
cd ~
rm -r geoserverTmp
echo "  ... done."






