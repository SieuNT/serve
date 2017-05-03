#!/usr/bin/env bash

# Variables
ACTION=$1
DOMAIN=$2
USERNAME=$3
OWNER=$(who am i | awk '{print $1}')
PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
DIR_ENABLE='/etc/apache2/sites-enabled/'
DIR_AVAILABLE='/etc/apache2/sites-available/'
HOSTS_EXISTS=$DIR_AVAILABLE$DOMAIN.conf
DIR_ROOT='/var/www/html'
DIR_USER=$DIR_ROOT$USERNAME
DIR_PUBLIC=${DIR_USER}

if [ "$(whoami)" != 'root' ]; then
		echo $"You have no permission to run $0 as non-root user. Use sudo"
		exit 1;
fi

if [ "$ACTION" != 'create' ] && [ "$ACTION" != 'remove' ]; then
		echo $"You neen to prompt for action (create or remove) -- Lover-case only"
		exit 1;
fi

if [ "$DOMAIN" == '' ] || [ "$USERNAME" == '' ]; then
		echo $"Please enter domain and username"
		exit 1;
fi

if [ "$ACTION" == 'create' ]; then
	# Check domain already exists
	if [ -e $HOSTS_EXISTS ]; then
		echo -e $"This domain already exists. Please try another one"
		exit 1;
	fi
	
	# Check dir exists or not
	if ! [ -d $DIR_USER ]; then
		sudo useradd -m $USERNAME
		sudo mkdir $DIR_PUBLIC
		sudo chown $USERNAME:$USERNAME $DIR_PUBLIC
		exit 1;
	fi
	
	if ! echo "
	<VirtualHost *:80>
		ServerName $DOMAIN
		ServerAlias www.$DOMAIN
		DocumentRoot $DIR_PUBLIC
		<Directory $DIR_PUBLIC>
			AllowOverride All
			Order allow,deny
			Allow from all
			Require all granted
		</Directory>
		ErrorLog /var/log/apache2/$USERNAME_error.log
		CustomLog /var/log/apache2/$USERNAME_access.log combined
	</VirtualHost>
	" > $HOSTS_EXISTS
	then
		echo -e $"Error!!!"
		exit 1;
	else
		a2ensite $DOMAIN
		sudo service apache2 restart
		echo -e $"Success!!"
		exit 1;
	fi
fi
