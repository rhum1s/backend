# Installation de Tomcat 7 sur Ubuntu 18 
#
# Avoir installé Oracle java JRE 8

cd ~ 
wget http://apache.mediamirrors.org/tomcat/tomcat-7/v7.0.86/bin/apache-tomcat-7.0.86.zip 
unzip apache-tomcat-7.0.86.zip 
rm apache-tomcat-7.0.86.zip
mv apache-tomcat-7.0.86 /opt/apache-tomcat7

echo 'CATALINA_HOME="/opt/apache-tomcat7"' | sudo tee -a /etc/environment
source /etc/environment
echo $CATALINA_HOME

cp /opt/apache-tomcat7/conf/tomcat-users.xml /opt/apache-tomcat7/conf/tomcat-users.xml.orig
echo '''

WARNING - Edit /opt/apache-tomcat7/conf/tomcat-users.xml adding the following:
<!-- user manager can access only manager section -->
<role rolename="manager-gui" />
<user username="manager" password="_SECRET_PASSWORD_" roles="manager-gui" />

<!-- user admin can access manager and admin section both -->
<role rolename="admin-gui" />
<user username="admin" password="_SECRET_PASSWORD_" roles="manager-gui,admin-gui" />

'''

read -p "Press enter once done to continue ...................."

cp /opt/apache-tomcat7/webapps/manager/META-INF/context.xml /opt/apache-tomcat7/webapps/manager/META-INF/context.xml.orig
cp /opt/apache-tomcat7/webapps/host-manager/META-INF/context.xml /opt/apache-tomcat7/webapps/host-manager/META-INF/context.xml.orig

echo """
WARNING - Comment the following lines in 
- /opt/apache-tomcat7/webapps/manager/META-INF/context.xml
- /opt/apache-tomcat7/webapps/host-manager/META-INF/context.xml

	<Valve className=\"org.apache.catalina.valves.RemoteAddrValve\"
           allow=\"127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1\" />
"""

read -p "Press enter once done to continue ...................."

chmod +x /opt/apache-tomcat7/bin/*
/opt/apache-tomcat7/bin/startup.sh

echo """
SUCCESS - Go to http://X.X.X.X:8080/
"""
