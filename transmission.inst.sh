#!/bin/bash

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/bin:/sbin

webuser=''
webpass=''

# Function to  create users for the webinterface
function SET_WEB_USER {
	while true; do
		echo -n "Please type the username for transmission webinterface, system user not required: "
		read webuser
		if [ -z $webuser ]; then
			echo
			echo "${RED}Something went wrong!"
			echo "You have entered an unusable username and/or different passwords.${NORMAL}"
			echo
		else
			break
		fi
	done
}

#function to set a user input password
set_pass() {
exec 3>&1 >/dev/tty
local LOCALPASS=''
local exitvalue=0
echo "Enter a password (6+ chars)"

while [ -z $LOCALPASS ]
do
  echo "Please enter the new password:"
  read -s password1

#check that password is valid
  if [ -z $password1 ]; then
    echo "password needs to be at least 6 chars long" && continue
  elif [ ${#password1} -lt 6 ]; then
    echo "password needs to be at least 6 chars long" && continue
  else
    echo "Enter the new password again:"
    read -s password2

# Check both passwords match
    if [ $password1 != $password2 ]; then
      echo "Passwords do not match"
    else
      LOCALPASS=$password1
    fi
  fi
done

exec >&3-
echo $LOCALPASS
return $exitvalue
}


#set password for transmission
SET_WEB_USER
echo "Set Password for transmission web client"
webpass=$(set_pass)

sudo apt-get install -y vim screen
sudo apt-get update -y
sudo apt-get install -y transmission-daemon
sudo service transmission-daemon stop

sudo sed -i 's/"dht-enabled.*/"dht-enabled": false,/g' /etc/transmission-daemon/settings.json
sudo sed -i 's/"download-dir.*/"download-dir": "\/home\/'$webuser'\/trdownloads",/g' /etc/transmission-daemon/settings.json
sudo sed -i 's/"encryption.*/"encryption": 2,/g' /etc/transmission-daemon/settings.json
sudo sed -i 's/"rpc-username.*/"rpc-username": "'$webuser'",/g' /etc/transmission-daemon/settings.json
sudo sed -i 's/"rpc-password.*/"rpc-password": "'$webpass'",/g' /etc/transmission-daemon/settings.json
sudo sed -i 's/"rpc-whitelist-enabled.*/"rpc-whitelist-enabled": false,/g' /etc/transmission-daemon/settings.json

sudo mkdir /home/$webuser/trdownloads
sudo chmod -R 775 /home/$webuser/trdownloads
#sudo usermod -a -G transmission root
#sudo chgrp -R debian-transmission /home/olpter/trdownloads

sudo service transmission-daemon start

cd /usr/share/transmission
wget https://github.com/tuzhishi/Rtorrent-Auto-Install/raw/master/Files/transmission-control-full.tar.gz
tar -xzf transmission-control-full.tar.gz