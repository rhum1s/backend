# Install nginx latest official repository version and extras package
# Testé avec Ubuntu 16.04.4 LTS
# FIXME: Package depends on ubuntu versions

# Exit on error
set -e

# Going home
cd ~

echo "- Adding nginx repository ..."
sudo touch /etc/apt/sources.list.d/nginx.list
echo "
deb http://nginx.org/packages/ubuntu/ xenial nginx
deb-src http://nginx.org/packages/ubuntu/ xenial nginx
" | sudo tee /etc/apt/sources.list.d/nginx.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
sudo apt-get update 
echo "... done." 

echo "- Installing nginx ..."
sudo apt-get install nginx-common
sudo apt-get install nginx-extras
if [ -f "/etc/nginx/nginx.conf.orig" ] ; then
	echo ""
else
	sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
fi
sudo chown -R rhum:root /etc/nginx
echo "... done."

echo "- Installing php7-fpm ..."
sudo apt-get install php7.0 php7.0-fpm
sudo systemctl restart php7.0-fpm
sudo systemctl status php7.0-fpm
sudo systemctl restart nginx
if [ -f "/etc/php/7.0/fpm/pool.d/www.conf.orig" ] ; then
	echo ""
else
	sudo cp /etc/php/7.0/fpm/pool.d/www.conf /etc/php/7.0/fpm/pool.d/www.conf.orig
fi
sudo sed -i -e "s/;listen.mode = 0660/listen.mode = 0660/g" /etc/php/7.0/fpm/pool.d/www.conf
if [ -f "/var/run/php/php7.0-fpm.sock" ] ; then
	sudo rm /var/run/php/php7.0-fpm.sock
fi
sudo service nginx restart
sudo service php7.0-fpm restart
echo "... done."

echo "- Create main page ..."
sudo touch /var/www/index.php
echo "<?php echo '*';?>" | sudo tee /var/www/index.php
echo "... done."

echo "- Creating default config file ..."
echo """
# NOTES: 
# Si alias, il faut utiliser $request_filename et pas $fastcgi_script_name pour script_filename.

user www-data;
worker_processes  2; # same as number of cores

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  text/html;
    sendfile        on;
    keepalive_timeout  65;
   
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	gzip on;
	gzip_disable 'msie6';
	
    # -- Localhost
    server {
	
        listen       80;
        server_name  localhost;
        
        # -- Main
        root /var/www;
        index index.php;              

        # location / {
            # auth_basic 'Login admin';
            # auth_basic_user_file /opt/nginx/logins/.htpasswd;
        # }
        
		location ~ \.php$ { 
			try_files $uri =404;  #If a file isn’t found, 404
			include /etc/nginx/fastcgi.conf; # Include Nginx’s fastcgi configuration
			fastcgi_pass unix:/run/php/php7.0-fpm.sock; # Look for the FastCGI Process Manager at this location 
		} 		
        
       

        # # -- Notebooks Jupyter
        # location /notebooks {
            # alias  /home/airpaca/web/notebooks;
            # # index  index.php;

            # auth_basic 'Login';
            # auth_basic_user_file /opt/nginx/.htpasswd.master;  
            
            # location ~ \.php$ {             
                # fastcgi_pass   127.0.0.1:9000;
                # fastcgi_index  index.php;
                # fastcgi_param  SCRIPT_FILENAME $request_filename;  
                # include        fastcgi_params;             
            # }  
                    
        # }          
        
        
    }
}

# mail {
	# # See sample authentication script at:
	# # http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript

	# # auth_http localhost/auth.php;
	# # pop3_capabilities 'TOP' 'USER';
	# # imap_capabilities 'IMAP4rev1' 'UIDPLUS';

	# server {
		# listen     localhost:110;
		# protocol   pop3;
		# proxy      on;
	# }

	# server {
		# listen     localhost:143;
		# protocol   imap;
		# proxy      on;
	# }
# }
""" | sudo tee /etc/nginx/nginx.conf
sudo nginx -t
echo "... done."

# Restart nginx
sudo systemctl restart nginx
sudo systemctl status nginx
