# Install Python3.6 
# Testé avec Ubuntu 16.04.4 LTS
# TIXME: Pas finalisé. Ne pas lancer en l'état.
# Exit on error
set -e

# Going home
cd ~

# FIXME: Verif dossier existe /mnt/sdb/jupyter_data

sudo add-apt-repository ppa:jonathonf/python-3.6
sudo apt update
sudo apt-get install python3.6
sudo apt-get install python3.6-dev

wget https://bootstrap.pypa.io/get-pip.py
sudo python3.6 get-pip.py
rm get-pip.py
pip3.6 -V

python3.6 -m pip install --upgrade pip
python3.6 -m pip install --user jupyter
jupyter --paths

# Configure
jupyter notebook --generate-config
TODO configurer /home/rhum/.jupyter/jupyter_notebook_config.py
# TODO: Recuperer tout ce qui est pas commenté dans le fichier
# TODO: pouvoir récupérer un hashed password avec python >>> from notebook.auth import passwd; passwd()

ip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
jupyter notebook --ip $ip &

# TODO: Soluton pour creation du hashed password http://jupyter-notebook.readthedocs.io/en/stable/public_server.html









