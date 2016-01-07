
# Installation nginx php fpm mariadb

Ce tutoriel permet d'installer nginx sur un serveur avec php5 fpm et mariadb. Il permet d'avoir un système multiutilisateur grâce à un espace de stockage personnel.


_Décembre 2015_  
_Technicien ES -  CPNV_  
_Miackaël Lacombe - Marco Visalli_

## Préparation de la machine

Forcer la mise à jour de debian
* apt-get update && apt-get upgrade   


## Installation de Nginx

Insertion des bons dépots

    nano /etc/apt/sources.list  
Commnentez toutes les lignes et ajoutez celle-ci :

    deb http://ftp.ch.debian.org/debian stable main
    deb http://security.debian.org/ wheezy/updates main

Installez Nginx

    apt-get install nginx

Configurez Nginx.conf dans /etc/nginx

    user nginx;
    worker_processes 1;
    access_log off;
    client_max_body_size 12m;  (dans le param http)

Rendez-vous dans /etc/nginx/sites-enable

    rm example_ssl.conf default.conf default

Créez une nouvelle configuration  
* Enlevez php pour mettre un simple fichier html à la racine du serveur  
* Créez une nouvelle configuration par défaut  
Pour la configuration de base il est conseillé  de remplacer le php par de l'html   


    nano maconfig.conf  


Insertion des fichiers dans /srv/data-user/votre-utilisateur
Copiez / collez ce code et modifiez le chemin d'accès

    server {  

    listen 80;
    root /chemin/vers/votre/site;
    index index.html index.htm;
      root /chemin/vers/votre/site;
      index index.html index.htm;

      server_name mydomainname.com www.mydomainname.com;

      location / {
              try_files $uri $uri/ /index.php;
      }

    }


## PHP5
Installation php fpm

    apt-get install php5-fpm php5-mysqlnd  
Modifier php.ini

    cd /etc/php5/fpm
    vi php.ini
    upload_max_filesize = 10M
    allow_url_fopen = Off
    post_max_size = 12M

Installez php fpm

    apt-get install php5-fpm php5-mysqlnd php5-mysql  

Rendez-vous dans le disser fpm

    cd /etc/php5/fpm  

Passez ces paramètres dans le fichier php.ini :
* vi php.ini
* upload_max_filesize = 10M
* allow_url_fopen = Off
* post_max_size = 12M

Executez un pool de php

    vim.tiny /etc/php5/fpm/pool.d/www.conf

user = nginx  
group = nginx  

listen.owner = nginx  
listen.group = nginx  

## Installation MariaDB

    apt-get install mariadb-server

Modifiez la config

    cd /etc/mysql  
    nano my.cnf  

Commentez la ligne \#bind-address = 127.0.0.1  
ajoutez cette ligne :
* skip-networking  

Créez un fichier newdomain.sh

    touch newdomain.sh

Ajoutez le droit d'execution de script  
Copiez le contenu du fichier script.sh du depot git

Executez le script

    ./newdomain.sh user


## A partir d'ici le script prend le relai pour la création d'espace par utilisateur. J'explique ici le processus du script

Créer un utilisateur dans le système linux
        * adduser user

Créer un répertoire dans
        * mkdir /srv/data-user   

Vous pouvez aussi installer le système de fichier ailleurs  
S'identifier avec un compte utilisateur, puis se connecter en root

Créer lien symbolique dans le home du user  
        * ln -s /srv/data-user/user /home/user/www

Changer les proprietaire pour donné accés au contenu au user
        * chown -vR user /srv/data-user/user

Changer le groupe pour permertre nginx de lire le dossier
        * chgrp -R nginx /srv/data-user/user

Régler les droits entre user
        * chmod 770 /srv/data-user/$1

Régler les droits dans le home
        *  chmod 770 /home/$1

Se connecter à maria db, en root pour le moment
        * mysql -u root -p


Crééer un utilisateur   
        * CREATE USER 'USER_NAME' IDENTIFIED BY 'PASSWORD';  

Créer database
        * CREATE DATABASE nomdevotredb;  

Donner les droits du user à la db
        * GRANT ALL PRIVILEGES ON nomdevotredb.* TO 'user'@'%'WITH GRANT OPTION;

Quitter MariaDB (ctrl+C) et se connecter avec l'utilisateur crée
        * mysql -u USER_NAME -p

Afficher toutes les bases de données
        * SHOW databases;

Selectionner la base de données crée
        * USE nomdevotredb;

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

Créer une config user dans nginx

        server {
            listen 80;
            root /srv/data-user/user;
            index index.php index.html index.htm;
            server_name www.user.ch;
            access_log /home/user/log/access.log
            location / {
                    try_files \$uri/ /index.php;
            }
            location ~ \.php$ {
                    try_files \$uri =404;
                    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                    include fastcgi_params;
                    fastcgi_pass unix:/var/run/php5-fpm-user.sock;
            }

        }


Créer un pool php par user pour avoir un php sécurisé, supprimer les autres fichier de config

        [$1]
        user = $1
        group = $1
        listen = /var/run/php5-fpm-$1.sock
        listen.owner = nginx
        listen.group = nginx
        pm = dynamic
        pm.max_children = 5
        pm.start_servers = 2
        pm.min_spare_servers = 1
        pm.max_spare_servers = 3
        chdir = /

Modifier votre fichier hosts sur windows pour rediriger un domaine sur l'ip du serveur
[ipdevotremachine] www.user.ch

- - -
## A partir d'ici c'est des commandes qui peuvent aider
Commande serveur
      systemctl restart nginx.service  
      systemctl restart php5-fpm.service  
      systemctl restart mysql.service  


- - -
### Attribuer propriétaire d'un répertorie à un utilisateur
      chown -vR user repertoire

- - -
## error log de nginx

      cat /var/log/nginx/error.log  

- - -
## Instance serveur par utilisateur site web

réer instance utilisateur php fpm   http://www.binarytides.com/php-fpm-separate-user-uid-linux/
## Instance serveur par utilisateur

Créer instance utilisateur php fpm   http://www.binarytides.com/php-fpm-separate-user-uid-linux/
