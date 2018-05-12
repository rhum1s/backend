 Installation de Tomcat
# Testé avec Ubuntu 16.04.4 LTS
# Avoir installé Oracle java JRE 8

# Exit on error
set -e

# Get host IP
ip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`

# Grab user vars
read -p 'Tomcat admin user: ' glgn
read -sp 'Tomcat admin password: ' gpwd
read -sp 'Geoserver data dir: ' gdd

echo "- WARNING - Will delete /opt/tomcat ..." 
cd ~ 
read -p "Press enter to continue"
if [ -d "/opt/tomcat" ]; then rm -r /opt/tomcat; fi
echo "  ... done."

echo "- Downloading Tomcat in /opt/tomcat ..."
wget http://apache.mediamirrors.org/tomcat/tomcat-7/v7.0.86/bin/apache-tomcat-7.0.86.zip
unzip apache-tomcat-7.0.86.zip
rm apache-tomcat-7.0.86.zip
mv apache-tomcat-7.0.86 /opt/tomcat
chmod +x /opt/tomcat/bin/*
echo "  ... done."

echo "- Backuping files that we'll overxrite ..."
cp /opt/tomcat/conf/tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml.orig
cp /opt/tomcat/webapps/manager/META-INF/context.xml /opt/tomcat/webapps/manager/META-INF/context.xml.orig
cp /opt/tomcat/webapps/host-manager/META-INF/context.xml /opt/tomcat/webapps/host-manager/META-INF/context.xml.orig
echo "  ... done."

echo "- Setting env ..."
echo 'CATALINA_HOME="/opt/tomcat"' | sudo tee -a /etc/environment
source /etc/environment
echo $CATALINA_HOME
echo "  ... done."

echo echo "- Creating tomcat setenv.sh ..."
cat /opt/tomcat/bin/setenv.sh <<EOL
export JAVA_HOME="/usr/lib/jvm/java-8-oracle"
export JRE_HOME="/usr/lib/jvm/java-8-oracle/jre"
export CATALINA_HOME="/opt/tomcat"
export JAVA_OPTS="-server -Duser.language=pt-US -Djava.awt.headless=true -Xms384M -Xmx512M -Xbootclasspath/a:/opt/tomcat/webapps/geoserver/WEB-INF/lib/marlin-0.7.5-Unsafe.jar -Dsun.java2d.renderer=org.marlin.pisces.MarlinRenderingEngine"
export GEOSERVER_DATA_DIR="$gdd"
export GEOSERVER_XSTREAM_WHITELIST="org.geoserver.rest.security.xml.JaxbUser" # For REST API bug when trying to create a user

# export CATALINA_OPTS="$CATALINA_OPTS -XX:SoftRefLRUPolicyMSPerMB=36000"
# export CATALINA_OPTS="$CATALINA_OPTS -XX:+UseParallelGC"
# export CATALINA_OPTS="$CATALINA_OPTS --XX:+UseParNewGC"
EOL
echo "  ... done."

echo "- Creating tomcat admin user ..."
cat > /opt/tomcat/conf/tomcat-users.xml <<EOL
<?xml version="1.0" encoding="utf-8"?>
<!--
See tomcat_users.xml.orig file for info
-->
<tomcat-users>
<!-- user manager can access only manager section -->
<role rolename="manager-gui" />
<user username="${glgn}" password="${gpwd}" roles="manager-gui" />

<!-- user admin can access manager and admin section both -->
<role rolename="admin-gui" />
<user username="${glgn}" password="${gpwd}" roles="manager-gui,admin-gui" />

</tomcat-users> 
EOL
echo "  ... done."

# No need for the following with Tomcat 7
#echo """
#WARNING - Comment the following lines in 
#- /opt/apache-tomcat7/webapps/manager/META-INF/context.xml
#- /opt/apache-tomcat7/webapps/host-manager/META-INF/context.xml
#
#	<Valve className=\"org.apache.catalina.valves.RemoteAddrValve\"
#           allow=\"127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1\" />
#"""

echo "- Starting Tomcat ..."
/opt/tomcat/bin/startup.sh
echo "  ... done."

echo "- Go to http://$ip:8080/"
