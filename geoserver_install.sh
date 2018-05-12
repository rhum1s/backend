# Install and configure Geoserver 2.13.0, 2.12.3 
# Testé avec Ubuntu 16.04.4 LTS
# Avoir installé Oracle java JRE 8
# Avoir installé Tomcat /opt/tomcat

# Exit on error
set -e

# Going home
cd ~

# Grab host ip
ip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`

# Grab user vars
read -sp 'Geoserver master password: ' gmpwd
read -sp 'Geoserver version: (12 or 13)' gv

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
if [ -d "~/geoserverTmp" ]; then rm -r ~/geoserverTmp; fi
mkdir ~/geoserverTmp
cd ~/geoserverTmp
wget -O geoserver.zip $gsurl 
unzip geoserver.zip
mv geoserver.war /opt/tomcat/webapps/
cd ~
rm -r geoserverTmp
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

echo "- Restarting Tomcat ..."
/opt/tomcat/bin/startup.sh
sleep 60s
echo "  ... done."

echo "- Setting Geoserver master password ..."
curl -u "admin:geoserver" -X PUT -H "Content-Type: application/json" -d '{"oldMasterPassword":"geoserver","newMasterPassword":'"$gmpwd"'}' http://$ip:8080/geoserver/rest/security/masterpw.xml
# curl -u "admin:$gmpwd" http://$ip:8080/geoserver/rest/security/masterpw.xml
echo "  ... done."

echo "- Creating Geoserver super user then deleting admin"
# http://host:8080/geoserver/rest/security/usergroup/service/default/users/
# curl -v -u "admin:geoserver" -X POST -H "Content-Type: applicon" -d '{"userName": "LLLL", "password": "LLLLLLL", enabled: true}' http://host:8080/geoserver/rest/security/usergroup/service/default/users/
echo "  ... done."

# Ending
echo "- Go to http://$ip:8080/geoserver"



