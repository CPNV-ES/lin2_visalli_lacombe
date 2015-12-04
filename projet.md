# Rapport d'installation nginx php fpm mariadb

bla bla bla bla

## Préparer la machine

Forcer la mise à jour de debian
* apt-get update && apt-get upgrade   

## installation de Nginx

nano /etc/apt/sources.list
commnenter toute les lignes et ajouter celle-ci :
* deb http://ftp.ch.debian.org/debian stable main
* deb http://security.debian.org/ wheezy/updates main


Installer nginx
apt-get install nginx

Configurer nginx.conf dans /etc/nginx  
* user nginx;
* worker_processes 1;
* access_log off;
* client_max_body_size 12m;  (dans le param http)

Aller dans /etc/nginx/sites-enable  
* rm example_ssl.conf default.conf default

Créer une nouvelle config  
nano maconfig.conf  
En collant ce contenu et modifier le chemin root  

- - -
server {
    listen 80;

    root /chemin/vers/votre/site;
    index index.php index.html index.htm;

    server_name mydomainname.com www.mydomainname.com;

    location / {
            try_files $uri $uri/ /index.php;
    }

    location ~ \.php$ {
            try_files $uri =404;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
            fastcgi_pass unix:/var/run/php5-fpm.sock;
    }
}
- - -  

## Installer php fpm
* apt-get install php5-fpm php5-mysqlnd  
Modifier php.ini
* cd /etc/php5/fpm
* vi php.ini
* upload_max_filesize = 10M
* allow_url_fopen = Off
* post_max_size = 12M

Corriger :
vim.tiny /etc/php5/fpm/pool.d/www.conf

user = nginx
group = nginx

listen.owner = nginx
listen.group = nginx



## Install MariaDB  

apt-get install mariadb-server

Modifier la config
cd /etc/mysql  
nano my.cnf  

Commenter cette ligne \#bind-address = 127.0.0.1  
ajouter cette ligne  
* skip-networking  

Se connecter à maria db en root pour le moment  

* mysql -u root -p

Crééer un utilisateur   
* CREATE USER 'USER_NAME' IDENTIFIED BY 'PASSWORD';  

Créer database
* CREATE DATABASE nomdevotredb;  

Donner les droits du user à la db
*
GRANT ALL PRIVILEGES ON nomdevotredb.* TO 'nomdevotreutilisateur'@'%' WITH GRANT OPTION;

## Gestion des droits

Créer lien symbolique  
ln -s /srv/data-user/marco /home/marco/www

Commande serveur
systemctl restart nginx.service  
systemctl restart php5-fpm.service  
systemctl restart mysql.service  

### Attribuer propriétaire d'un répertorie à un utilisateur
chown -vR user repertorie

## var du serveur nginx

cat /var/log/nginx/error.log  

Créer instance utilisateur php fpm   http://www.binarytides.com/php-fpm-separate-user-uid-linux/
