
# Installation d'un serveur web avec nginx php fpm mariadb

Ce tutoriel permet d'installer nginx sur un serveur avec php5 fpm et mariadb. Il permet d'avoir un système multiutilisateur grâce à un espace de stockage personnel.


_Décembre 2015_  
_Technicien ES -  CPNV_  
_Mickaël Lacombe - Marco Visalli_

## Préparation de la machine

Le projet est prévu pour une distribution **Debian 8** (jessie)  

Je met ici le lien direct pour la version 64bits que nous avons utilisé.

http://cdimage.debian.org/debian-cd/8.2.0/amd64/iso-cd/debian-8.2.0-amd64-netinst.iso

Vous pouvez l'installer en créant une clé usb ou un cd bootable *Il y a beaucoups d'info sur internet pour cette partie*  

### Installation Debian  

Lors de l'installation il n'y a pas de point sensible, il faut juste rentrer les données demandées à l'écran, comme le compte root, etc.

### Commande après installation

Dés que l'installation est finie, il y a quelques manipulations à effectuer

Forcer la mise à jour de debian

        apt-get update && apt-get upgrade

Insertion des dépots

    nano /etc/apt/sources.list   

Commnentez toutes les lignes et ajoutez celle-ci :

    deb http://ftp.ch.debian.org/debian stable main
    deb http://security.debian.org/ jessie/updates main


## Installation de Nginx

Installez Nginx

    apt-get install nginx

Configurez Nginx.conf

    nano /etc/nginx/nginx.conf

 Modifier ces informations

    user nginx;
    worker_processes 1;
    access_log off;
    client_max_body_size 12m;  (dans le param http)

Rendez-vous dans /etc/nginx/sites-enable et supprimer les config par défaut

    rm example_ssl.conf default.conf default

Créez une nouvelle configuration

        nano maconfig.conf  

Pour la config de base je préconise d'enlever php pour mettre un simple fichier à la racine du serveur html    
Coller ce contenu et modifier le chemin root  
Pour ma part j'ai décidé de mettre les fichiers des utilisateurs dans /srv/data-user/votre-utilisateur

    server {  
    listen 80;
    root /chemin/vers/votre/site;
    index index.html index.htm;
    server_name votre_domaine.com www.votre_domaine.com;
      location / {
              try_files $uri $uri/ /index.html;
      }
    }


## PHP5
Installation php fpm

    apt-get install php5-fpm php5-mysqlnd  

Modifier php.ini

    cd /etc/php5/fpm

Trouver et modifier ces informations

    vi php.ini
    upload_max_filesize = 10M
    allow_url_fopen = Off
    post_max_size = 12M

Installez php fpm

    apt-get install php5-fpm php5-mysqlnd php5-mysql  

Rendez-vous dans le dossier fpm

    cd /etc/php5/fpm  

Passez ces paramètres dans le fichier php.ini :

        nano php.ini

        upload_max_filesize = 10M
        allow_url_fopen = Off
        post_max_size = 12M

## Installation MariaDB

Installer mariadb

    apt-get install mariadb-server

Modifiez la config

    cd /etc/mysql   

    nano my.cnf  

Commentez la ligne \#bind-address = 127.0.0.1  

ajoutez cette ligne :

    skip-networking  

# Script
A paritr d'ici le script automatise la création d'utilisateur avec son espace personnel et la configuration pour l'utilisateur

Créez un fichier newdomain.sh

    touch newdomain.sh

Ajoutez le droit d'execution de script  

        chmod +x newdomain.sh

Copiez le contenu du fichier script.sh du dépot git

Exécutez le script

    ./newdomain.sh nomdevotreutilisateur

Donnez les informations demandées

### local
Il es possible si vous êtes sous windows et travaillez en localhost de naviguer via un domaine propre comme votresite.com

Modifiez votre fichier C:\Windows\System32\drivers\etc\hosts

    [ipdevotremachine] www.votresite.com

## Processus du script
Voici la description complète du script si vous voulez l'améliorer ou l'adapter selon votre besoin

Créez un utilisateur dans le système linux

    adduser user

Créez un répertoire dans /srv/data-user

    mkdir /srv/data-user   

Il est possible d'installer le système de fichier ailleurs

S'identifier avec un compte utilisateur, puis se connecter en root

Créez un lien symbolique dans le home du user

    ln -s /srv/data-user/user /home/user/www

Changez les proprietaires pour donner accés au contenu au user

    chown -vR user /srv/data-user/user

Changez le groupe pour permertre nginx de lire le dossier

    chgrp -R nginx /srv/data-user/user

Réglez les droits entre user

    chmod 770 /srv/data-user/$1

Réglez les droits dans le home

    chmod 770 /home/$1

Se connecter à maria db, en root

    mysql -u root -p


Crééz un utilisateur

    CREATE USER 'USER_NAME' IDENTIFIED BY 'PASSWORD';  

Créez database

    CREATE DATABASE nomdevotredb;  

Donnez les droits du user à la db

    GRANT ALL PRIVILEGES ON nomdevotredb.* TO 'user'@'%'WITH GRANT OPTION;

Quittez MariaDB (ctrl+C) et se connecter avec l'utilisateur crée

    mysql -u USER_NAME -p

Affichez toutes les bases de données

    SHOW databases;

Selectionnez la base de données crée

    USE nomdevotredb;

Donnez les droits du user à la db

    GRANT ALL PRIVILEGES ON nomdevotredb.* TO 'nomdevotreutilisateur'@'%' WITH GRANT OPTION;  

Attribution d'un espace personnel à un utilisateur

    adduser nomutilisateur  

Créez une config user dans nginx

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


Créez un pool php par user pour des raisons de sécurité  
Supprimez les autres fichiers de config

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

_Fin du script_

## Reboot des services

Commande serveur :

    systemctl restart nginx.service  
    systemctl restart php5-fpm.service  
    systemctl restart mysql.service  
