# Install and configure Geoserver 2.13.0, 2.12.3 
# Testé avec Ubuntu 16.04.4 LTS
# Avoir installé Oracle java JRE 8
# Avoir installé Tomcat /opt/tomcat

# Exit on error
set -e

# Going home
cd ~

# Warning ! Will delete all
read -p """
ATTENTION - 
Va supprimer toutes les données dans 
/opt/tomcat/webapps/geoserver

Souhaitez vous vraiment continuer? (y/n): 
""" -n 1 -r
echo  
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Lets'go"
else 
    exit
fi

# Grab host ip
ip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`

# Grab user vars
read -p 'Geoserver admin login: ' gmlgn
read -sp 'Geoserver admin and master password: ' gmpwd
read -p 'Geoserver version: (12 or 13)' gv

# Treating geoserver version for the good url etc.
if [ $gv == 12 ]; then 
    gsurl='https://sourceforge.net/projects/geoserver/files/GeoServer/2.12.3/geoserver-2.12.3-war.zip/download' 
else 
    gsurl="https://sourceforge.net/projects/geoserver/files/GeoServer/2.13.0/geoserver-2.13.0-war.zip/download"
fi

echo "- Stoping Tomcat ..."
/opt/tomcat/bin/shutdown.sh
sleep 5s
echo "  ... done."

echo "- Removing /opt/tomcat/webapps/geoserver* ..."
if [ -f "/opt/tomcat/webapps/geoserver.war" ]; then rm /opt/tomcat/webapps/geoserver.war; fi
if [ -d "/opt/tomcat/webapps/geoserver" ]; then rm -r /opt/tomcat/webapps/geoserver; fi
echo "  ... done."

echo "- Installing Oracle JRE 8 NATIVE JAI ..."
cd ~  
wget http://data.opengeo.org/suite/jai/jai-1_1_3-lib-linux-amd64-jdk.bin
sudo mv jai-1_1_3-lib-linux-amd64-jdk.bin /usr/lib/jvm/java-8-oracle/
cd /usr/lib/jvm/java-8-oracle/
sudo sh jai-1_1_3-lib-linux-amd64-jdk.bin
sudo rm jai-1_1_3-lib-linux-amd64-jdk.bin
cd ~
echo "  ... done."

# Archive Truncate !?
# echo "- Installing Oracle JRE 8 Image I/O ..."
# wget http://data.opengeo.org/suite/jai/jai_imageio-1_1-lib-linux-amd64-jdk.bin
# sudo mv jai_imageio-1_1-lib-linux-amd64-jdk.bin /usr/lib/jvm/java-8-oracle/
# cd /usr/lib/jvm/java-8-oracle/
# sudo sh jai_imageio-1_1-lib-linux-amd64-jdk.bin
# sudo rm jai_imageio-1_1-lib-linux-amd64-jdk.bin
# cd ~
# echo "  ... done."

echo "- Installing Oracle JRE 8 Image I/O ..."
cd ~
wget http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz
tar -zxvf jai_imageio-1_1-lib-linux-amd64.tar.gz
rm jai_imageio-1_1-lib-linux-amd64.tar.gz
cd jai_imageio-1_1/lib
sudo mv *.jar /usr/lib/jvm/java-8-oracle/jre/lib/ext/
sudo mv *.so /usr/lib/jvm/java-8-oracle/jre/lib/amd64/
cd ~
rm -r jai_imageio-1_1
echo "  ... done."

echo "- Installing Oracle JCE Policy 8 ..."
cd  ~
if [ -f "/usr/lib/jvm/java-8-oracle/jre/lib/security/policy/unlimited/local_policy.jar" ]; then sudo cp /usr/lib/jvm/java-8-oracle/jre/lib/security/policy/unlimited/local_policy.jar /usr/lib/jvm/java-8-oracle/jre/lib/security/policy/unlimited/local_policy.jar.orig; fi
if [ -f "/usr/lib/jvm/java-8-oracle/jre/lib/security/policy/unlimited/local_policy.jar" ]; then sudo cp /usr/lib/jvm/java-8-oracle/jre/lib/security/policy/unlimited/US_export_policy.jar /usr/lib/jvm/java-8-oracle/jre/lib/security/policy/unlimited/US_export_policy.jar.orig; fi
wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip
unzip jce_policy-8.zip
rm jce_policy-8.zip
sudo mv UnlimitedJCEPolicyJDK8/*.jar /usr/lib/jvm/java-8-oracle/jre/lib/security/policy/unlimited/
rm -r UnlimitedJCEPolicyJDK8
echo "  ... done."

echo "- Installing Geoserver ..."
if [ -d "/tmp/geoserverTmp" ]; then rm -r /tmp/geoserverTmp; fi
mkdir /tmp/geoserverTmp
cd /tmp/geoserverTmp
wget -O geoserver.zip $gsurl 
unzip geoserver.zip
mv geoserver.war /opt/tomcat/webapps/
cd ~
rm -r /tmp/geoserverTmp
echo "  ... done."

echo "- Restarting Tomcat for Geoserver to create files ..."
/opt/tomcat/bin/startup.sh
sleep 30s
echo "  ... done."

echo "- Stoping Tomcat ..."
/opt/tomcat/bin/shutdown.sh
sleep 5s
echo "  ... done."

echo "- Moving Geoserver jai_*.jar files (*.orig) ..."
mv /opt/tomcat/webapps/geoserver/WEB-INF/lib/jai_codec-1.1.3.jar /opt/tomcat/webapps/geoserver/WEB-INF/lib/jai_codec-1.1.3.jar.orig
mv /opt/tomcat/webapps/geoserver/WEB-INF/lib/jai_core-1.1.3.jar /opt/tomcat/webapps/geoserver/WEB-INF/lib/jai_core-1.1.3.jar.orig
mv /opt/tomcat/webapps/geoserver/WEB-INF/lib/jai_imageio-1.1.jar /opt/tomcat/webapps/geoserver/WEB-INF/lib/jai_imageio-1.1.jar.orig 
echo "  ... done."

echo "- Enabeling CORS in web.xml and changing filter for tomcat instead of jetty..."
# Pour chaque header CORS dans le fichier de config
# Calcul des numeros de lignes +1 et +4
# Remplacement du texte en supprimant les commentaires
first_done=0
grep -n '<!-- Uncomment following filter to enable CORS -->' /opt/tomcat/webapps/geoserver/WEB-INF/web.xml | awk -F  ":" '{print $1}' | while read line; do

    line_p1="$(($line + 1))"
    line_p4="$(($line + 4))"
    line_p3="$(($line + 3))"

    if [ $first_done == 0 ]
    then
        sed -i -e  "$line_p1""s/.*/<filter>/" /opt/tomcat/webapps/geoserver/WEB-INF/web.xml
        sed -i -e  "$line_p4""s/.*/<\/filter>/" /opt/tomcat/webapps/geoserver/WEB-INF/web.xml
        sed -i -e  "$line_p3""s/.*/<filter-class>org.apache.catalina.filters.CorsFilter<\/filter-class>/" /opt/tomcat/webapps/geoserver/WEB-INF/web.xml # Changing jetty filter for tomcat one
        first_done=1
    else
        sed -i -e  "$line_p1""s/.*/<filter-mapping>/" /opt/tomcat/webapps/geoserver/WEB-INF/web.xml
        sed -i -e  "$line_p4""s/.*/<\/filter-mapping>/" /opt/tomcat/webapps/geoserver/WEB-INF/web.xml
    fi
done
echo "  ... done."

echo "- Installation des extensions pré-sélectionnées ..."
# FIXME: URL différentes selon la version
install_module(){
        # install_module "http://..."
        cd /tmp
        if [ -d "/tmp/module" ]; then rm -r /tmp/module; fi
        mkdir /tmp/module
        url=$1;
        wget -O module.zip "${url}"
        unzip -o module.zip -d module
        mv module/*.jar /opt/tomcat/webapps/geoserver/WEB-INF/lib/
}

if [ $gv == 12 ]; then
    gsv="2.12.3"
else
    gsv="2.13.0"
fi

# CSS Styling
install_module "https://sourceforge.net/projects/geoserver/files/GeoServer/${gsv}/extensions/geoserver-${gsv}-css-plugin.zip/download"
# YSLD Styling
install_module "https://sourceforge.net/projects/geoserver/files/GeoServer/${gsv}/extensions/geoserver-${gsv}-ysld-plugin.zip/download"
# INSPIRE
install_module "https://sourceforge.net/projects/geoserver/files/GeoServer/${gsv}/extensions/geoserver-${gsv}-inspire-plugin.zip/download"
# CSW
install_module "https://sourceforge.net/projects/geoserver/files/GeoServer/${gsv}/extensions/geoserver-${gsv}-csw-plugin.zip/download"
# ImagePyramid
install_module "https://sourceforge.net/projects/geoserver/files/GeoServer/${gsv}/extensions/geoserver-${gsv}-pyramid-plugin.zip/download"
# Vector Tiles
install_module "https://sourceforge.net/projects/geoserver/files/GeoServer/${gsv}/extensions/geoserver-${gsv}-vectortiles-plugin.zip/download"
# WPS
install_module "https://sourceforge.net/projects/geoserver/files/GeoServer/${gsv}/extensions/geoserver-${gsv}-wps-plugin.zip/download"
# WCS 2.0 EO
install_module "https://sourceforge.net/projects/geoserver/files/GeoServer/${gsv}/extensions/geoserver-${gsv}-wcs2_0-eo-plugin.zip/download"
echo "  ... done."

echo "- Restarting Tomcat ..."
/opt/tomcat/bin/startup.sh
sleep 60s
echo "  ... done."

echo "- Setting Geoserver master password ..."
curl -u "admin:geoserver" -X PUT -H "Content-Type: application/json" -d '{"oldMasterPassword":"geoserver","newMasterPassword":'"$gmpwd"'}' http://$ip:8080/geoserver/rest/security/masterpw.xml
echo "  ... done."

echo "- Creating Geoserver super user then deleting admin"
curl -v -u "admin:geoserver" -X POST -H "Content-Type: application/json" -d '{"org.geoserver.rest.security.xml.JaxbUser":{"userName": "'"$gmlgn"'", "password": "'"$gmpwd"'", enabled: true}}' http://$ip:8080/geoserver/rest/security/usergroup/service/default/users/
curl -v -u "admin:geoserver" -X POST http://$ip:8080/geoserver/rest/security/roles/service/default/role/ADMIN/user/$gmlgn
curl -v -u "$gmlgn:$gmpwd" -X DELETE http://$ip:8080/geoserver/rest/security/usergroup/service/default/user/admin
echo "  ... done."

# Ending
echo "- Go to http://$ip:8080/geoserver"

