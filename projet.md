- - -
# Installation d'un serveur web avec nginx php fpm mariadb

Ce tutoriel permet d'installer le serveur nginx sur un serveur avec php5 fpm et mariadb. Il permet d'avoir un système multiutilisateur grâce à un espace de stockage personnel.

Bonne lecture :bowtie:

_Décembre 2015_  
_Technicien ES -  CPNV_
- - -
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



Forcer la mise à jour de debian
* apt-get update && apt-get upgrade   

- - -
## Installation de Nginx

On va mettre les bons dépots
* nano /etc/apt/sources.list
commnenter toute les lignes et ajouter celle-ci :
* deb http://ftp.ch.debian.org/debian stable main
* deb http://security.debian.org/ wheezy/updates main

Installer nginx
* apt-get install nginx

Configurer nginx.conf dans /etc/nginx  
* user nginx;
* worker_processes 1;
* access_log off;
* client_max_body_size 12m;  (dans le param http)

Aller dans /etc/nginx/sites-enable  
* rm example_ssl.conf default.conf default

Créer une nouvelle config  
* de base enlever php pour mettre un simple html à la racine du serveur  
Créer une nouvelle config par défaut
* pour la config de base je préconise d'enlever php pour mettre un simple html   

* nano maconfig.conf  

En collant ce contenu et modifier le chemin root  
Pour ma part j'ai décidé de mettre les fichiers dans /srv/data-user/votre-utilisateur


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

- - -
## PHP5
Installer php fpm
* apt-get install php5-fpm php5-mysqlnd  
Modifier php.ini
* cd /etc/php5/fpm
* vi php.ini
* upload_max_filesize = 10M
* allow_url_fopen = Off
* post_max_size = 12M

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

* apt-get install mariadb-server

Modifier la config
* cd /etc/mysql  
* nano my.cnf  

Commenter cette ligne \#bind-address = 127.0.0.1  
ajouter cette ligne  
* skip-networking  

## Créer un fichier newdomain.sh
  touch newdomain.sh

Ajouter le droit d'execution de script  
copier le contenu du fichier script.sh du depos git

Executer le script
./newdomain.sh user

- - -
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
