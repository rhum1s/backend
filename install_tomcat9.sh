# Installation de Tomcat 9 sur Ubuntu 18 
# Pas encore de dépot !? Uniquement v8 !?
#
# Avoir installé Oracle java JRE 8

cd ~

wget http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.8/bin/apache-tomcat-9.0.8.zip
unzip apache-tomcat-9.0.8.zip
rm apache-tomcat-9.0.8.zip
mv apache-tomcat-9.0.8 /opt/apache-tomcat9

echo 'CATALINA_HOME="/opt/apache-tomcat9"' | sudo tee -a /etc/environment
source /etc/environment
echo $CATALINA_HOME

cp /opt/apache-tomcat9/conf/tomcat-users.xml /opt/apache-tomcat9/conf/tomcat-users.xml.orig
echo '''

WARNING - Edit /opt/apache-tomcat9/conf/tomcat-users.xml adding the following:
<!-- user manager can access only manager section -->
<role rolename="manager-gui" />
<user username="manager" password="_SECRET_PASSWORD_" roles="manager-gui" />

<!-- user admin can access manager and admin section both -->
<role rolename="admin-gui" />
<user username="admin" password="_SECRET_PASSWORD_" roles="manager-gui,admin-gui" />

'''

read -p "Press enter once done to continue ...................."

cp /opt/apache-tomcat9/webapps/manager/META-INF/context.xml /opt/apache-tomcat9/webapps/manager/META-INF/context.xml.orig
cp /opt/apache-tomcat9/webapps/host-manager/META-INF/context.xml /opt/apache-tomcat9/webapps/host-manager/META-INF/context.xml.orig

echo """
WARNING - Comment the following lines in 
- /opt/apache-tomcat9/webapps/manager/META-INF/context.xml
- /opt/apache-tomcat9/webapps/host-manager/META-INF/context.xml

	<Valve className=\"org.apache.catalina.valves.RemoteAddrValve\"
           allow=\"127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1\" />
"""

read -p "Press enter once done to continue ...................."

chmod +x /opt/apache-tomcat9/bin/*
/opt/apache-tomcat9/bin/startup.sh

echo """
SUCCESS - Go to http://X.X.X.X:8080/
"""
