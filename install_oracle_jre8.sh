# Install Oracle JDK 8 (JRE + dev)
# Testé avec Ubuntu 16.04.4 LTS

# Exit on error
set -e

cd ~

sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
echo "Grab a coffee"
sudo apt-get install oracle-java8-installer

echo "Testing Java ..."
java -version
javac -version

echo "Choose Java version if multiple installed"
sudo update-alternatives --config java

echo "Choose Javac version if multiple installed"
sudo update-alternatives --config javac

echo "Adding JAVA_HOME and JRE_HOME ..."
echo 'JAVA_HOME="/usr/lib/jvm/java-8-oracle"' | sudo tee -a /etc/environment
echo 'JRE_HOME="/usr/lib/jvm/java-8-oracle/jre"' | sudo tee -a /etc/environment
source /etc/environment
echo $JAVA_HOME
echo $JRE_HOME

# echo "Installing NATIVE JAI"
# wget http://data.opengeo.org/suite/jai/jai-1_1_3-lib-linux-amd64-jdk.bin
# sudo mv jai-1_1_3-lib-linux-amd64-jdk.bin /usr/lib/jvm/java-8-oracle/
# cd /usr/lib/jvm/java-8-oracle/
# sudo sh jai-1_1_3-lib-linux-amd64-jdk.bin
# sudo rm jai-1_1_3-lib-linux-amd64-jdk.bin
# cd ~

# echo "Installing Java Image I/O"
# wget http://data.opengeo.org/suite/jai/jai_imageio-1_1-lib-linux-amd64-jdk.bin
# sudo mv jai_imageio-1_1-lib-linux-amd64-jdk.bin /usr/lib/jvm/java-8-oracle/
# cd /usr/lib/jvm/java-8-oracle/
# sudo sh jai_imageio-1_1-lib-linux-amd64-jdk.bin
# sudo rm jai_imageio-1_1-lib-linux-amd64-jdk.bin
#  cd ~

# echo "End of installation - DO NOT FORGET THE FOLLOWING STEPS:"

# echo "Do not forget to remove original JAI files from the GeoServer WEB-INF/lib folder"
# echo "http://docs.geoserver.org/stable/en/user/production/java.html#production-java"

# echo "Download policies from http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html" and replace the two files in JRE_HOME/lib/security"

