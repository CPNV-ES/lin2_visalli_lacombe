# Rapport d'installation nginx php fpm mariadb

bla bla bla bla

## Préparer la machine

Forcer la mise à jour de debian
* apt-get update && apt-get upgrade   

## Installation de Nginx

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

Créer une nouvelle config par défaut
* pour la config de base je préconise d'enlever php pour mettre un simple html   

nano maconfig.conf  

En collant ce contenu et modifier le chemin root  
Pour ma part j'ai décidé de mettre les fichiers dans /srv/data-user/votre-utilisateur

--  
server {  

    listen 80;
    root /chemin/vers/votre/site;
    index index.html index.htm;

    server_name mydomainname.com www.mydomainname.com;

    location / {
            try_files $uri $uri/ /index.php;
    }    
}
--

## Installer php fpm
Ensuite nous allons installer les paquets pour php
* apt-get install php5-fpm php5-mysqlnd php5-mysql  

Configuration de base, modifier php.ini

cd /etc/php5/fpm  

* vi php.ini
* upload_max_filesize = 10M
* allow_url_fopen = Off
* post_max_size = 12M

Ensuite nous nous occupons des pool php
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

S'identifier avec un compte utilisateur, puis se connecter en root

* mysql -u root -p

Crééer un utilisateur   
* CREATE USER 'USER_NAME' IDENTIFIED BY 'PASSWORD';  
CREATE USER 'test'@'%' IDENTIFIED BY '';

Créer database
* CREATE DATABASE nomdevotredb;  

Donner les droits du user à la db  
* GRANT ALL PRIVILEGES ON nomdevotredb.* TO 'nomdevotreutilisateur'@'%' WITH GRANT OPTION;  

Quitter MariaDB (ctrl+C) et se connecter avec l'utilisateur crée  
* mysql -u USER_NAME -p  

Afficher toutes les bases de données
* SHOW databases;

Selectionner la base de données crée  
* USE nomdevotredb;

### Quelques requêtes utiles pour commencer

Créer une table dans la base de données  
* CREATE TABLE 'nomdevotredb'.'nomdevotretable' ( 'nomdevotrecolonne' INT NOT NULL ) ENGINE = InnoDB;  

Insérer des données dans la base de données  
* INSERT INTO 'nomdevotredb'.'nomdevotretable' ('nomdevotrecolonne') VALUES ('votrevaleur');  


REVOKE DROP ON tutorial_database.* FROM 'testuser'@'localhost';

GRANT DROP ON TABLE thedatabase.* TO user1

## Attribué un espace personnel à un utilisateur

* adduser nom-utilisateur  

Lancer le script
Remplir les informations demandées

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

## Instance serveur par utilisateur

Créer instance utilisateur php fpm   http://www.binarytides.com/php-fpm-separate-user-uid-linux/
