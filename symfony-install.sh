#!/bin/bash

#get vars
IP=$(cat ip.var | grep "")
echo "Your Symfony Project name : "
read name
echo "$name" > name.var
mkdir ~/$name
clear

Symfony-Installer(){
	ssh -i centos -t centos@$IP << EOF
	#switch user to su
   	#Installing Symfony Framework
	echo "Installing Symfony Framework..."
	sudo su
	curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
	chmod a+x /usr/local/bin/symfony
	/usr/local/bin/symfony new /home/centos/$name
	/home/centos/$name/bin/console server:start $IP
EOF
}

Symfony-Server-Manager(){
while true
do
  clear
  echo "\t MENU OF CHOICES

\t r -- \t Start Server
\t s -- \t Stop Server
\t c -- \t Get Symfony Console

\t Q -- \t QUIT (Leave this menu program)

\t tape RETURN to go back \c"

  read answer
  clear

  case "$answer" in
    [Rr]*) Server-start ;;
    [Ss]*) Server-stop ;;
    [Cc]*) Symfony-console ;;

    [Qq]*)  echo "Exit" ; exit 0 ;;
    *)      echo "Tape your choice:" ;;
  esac
  echo ""
  echo "tapez RETURN pour le menu"
  read dummy
done

}

Server-start(){
	ssh -i centos -t centos@$IP << EOF
	#switch user to su
   	#Installing Symfony Framework
	echo "Starting Symfony web server at $IP..."
	/home/centos/$name/bin/console server:start $IP 
	#symfony new $name
	#cd $name/bin
	#php console server:start $IP
EOF
}
Server-stop(){
	ssh -i centos -t centos@$IP << EOF
	#switch user to su
   	#Installing Symfony Framework
	echo "Stopping Symfony web server at $IP..."
	/home/centos/$name/bin/console server:stop $IP
EOF
}

Symfony-console(){
		ssh -i centos -t centos@$IP << EOF
	#switch user to su
   	#Installing Symfony Framework
	echo "Starting Symfony console ..."
	/home/centos/$name/bin/console
  read com
  /home/centos/$name/bin/console $com
EOF

}

Deploy-Symfony-Project(){
	echo "null"
}

while true
do
  clear
  echo "\t MENU OF CHOICES

\t i -- \t Symfony-Installer
\t s -- \t Symfony-Server-Manager
\t d -- \t Deploy-Symfony-Project 

\t Q -- \t QUIT (Leave this menu program)

\t tape RETURN to go back \c"

  read answer
  clear

  case "$answer" in
    [Ii]*) Symfony-Installer ;;

    [Ss]*) Symfony-Server-Manager ;;
    [Dd]*) Deploy-Symfony-Project ;;

    [Qq]*)  echo "sortie du program" ; exit 0 ;;
    *)      echo "Choisissez une option affichee dans le menu:" ;;
  esac
  echo ""
  echo "tapez RETURN pour le menu"
  read dummy
done