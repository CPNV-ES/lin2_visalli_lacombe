
#!/bin/bash
# Script by Mickael
# Config auto for  nginx/php fpm on debian
#
#
#

line='-----------------------------------------------'

if [ "$1" == "" ]; then
         >&2 echo "Thanks to entry a user name"
        exit 1
fi
        echo "The user name is : $1"
        echo $line
        adduser $1
        echo $line
        mkdir /srv/data-user/$1
        echo $line
        ln -s /srv/data-user/$1 /home/$1/www
        echo $line
        chown -vR $1 /srv/data-user/$1
        echo $line
        chgrp -R nginx /srv/data-user/$1
        echo $line
        chmod 770 /srv/data-user/$1
        echo $line
        chmod 770 /home/$1
        echo $line
cat << EOF>  /etc/nginx/sites-enabled/$1.conf
server {
    listen 80;
    root /srv/data-user/$1;
    index index.php index.html index.htm;
    server_name www.$1.ch;
    access_log /home/$1/log/access.log
    location / {
            try_files \$uri/ /index.php;
    }
    location ~ \.php$ {
            try_files \$uri =404;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
            fastcgi_pass unix:/var/run/php5-fpm-$1.sock;
    }

}
EOF
        echo $line

cat << EOF > /etc/php5/fpm/pool.d/$1.conf
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
EOF

echo $line
echo "Entry the root password for access to mysql : "
echo "CREATE USER '$1'@'localhost' IDENTIFIED BY '123'; create database $1; GRANT ALL PRIVILEGES ON $1.* TO '$1'@'localhost' WITH GRANT OPTION;" | mysql -u root -p



