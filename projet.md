
# Installation d'un serveur web avec nginx php fpm mariadb

Ce tutoriel permet d'installer nginx sur un serveur avec php5 fpm et mariadb. Il permet d'avoir un système multiutilisateur grâce à un espace de stockage personnel.


_Décembre 2015_  
_Technicien ES -  CPNV_  
_Mickaël Lacombe - Marco Visalli_

## Préparation de la machine

Le projet est prévu pour une distribution Debian 8 (jessie)  
Dans un premier temps nous allons télécharger l'iso pour l'installer, selon votre machine physique l'iso à prendre est différent.

Je met ici le lien direct pour la version 64bits étant donné que c'est la configuration la plus largement répandue.

http://cdimage.debian.org/debian-cd/8.2.0/amd64/iso-cd/debian-8.2.0-amd64-netinst.iso

Si votre machine ne correspond pas, vous pouvez trouver votre iso à cette adresse https://www.debian.org/releases/jessie/

Si vous utilisez un logiciel de virtualisation pour mettre en place le serveur il suffit de créer une nouvelle machine virtuel avec l'iso téléchargé.

Si vous voulez installer Debian sur une machine physique je vous conseille de suivre ces instructions.
Il faut créer une clé usb ou un cb bootable, vous pouvez utiliser ce logiciel
http://sourceforge.net/projects/win32diskimager/

Il suffit de sélectionner l'iso et le périphérique (attention le périphérique sera formaté)
Dans votre bios sélectionner votre périphérique en priorité et rédémarré.
Votre machine devrait démarrer sur votre iso et commencé l'installation de debian

## Installation de Nginx

Insertion des dépots

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
Pour la configuration de base il est conseillé de remplacer le php par de l'html   

    nano maconfig.conf  

Insertion des fichiers dans /srv/data-user/votre-utilisateur
Copiez / collez ce code et modifiez le chemin d'accès

    server {  

    listen 80;
    root /chemin/vers/votre/site;
    index index.html index.htm;
      root /chemin/vers/votre/site;
      index index.html index.htm;

      server_name votre_nom_de_domaine.com.com www.votre_nom_de_domaine.com.com;

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

    skip-networking  

Créez un fichier newdomain.sh

    touch newdomain.sh

Ajoutez le droit d'execution de script  
Copiez le contenu du fichier script.sh du depot git

Executez le script

    ./newdomain.sh user


## Processus du script

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

Executez le script
Donnez les informations demandées
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

Modifiez votre fichier hosts depuis windows pour rediriger un domaine sur l'ip du serveur

    [ipdevotremachine] www.user.ch

## Reboot des services
Commande serveur :

    systemctl restart nginx.service  
    systemctl restart php5-fpm.service  
    systemctl restart mysql.service  
