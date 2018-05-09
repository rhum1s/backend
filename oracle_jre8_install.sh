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

