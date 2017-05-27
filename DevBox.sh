#!/bin/bash
while true
do
echo "===================================="
echo "DevBoxGenerator Menu"
echo "===================================="
echo "Enter 1 to create a KVM machine 1: "
echo "Enter 2 to generate ssh certs 2: "
echo "Enter 3 to install tools (PHP,DB,etc...) 3: "
echo "Enter 4 to generate Symfony project 4: "
echo "Enter 5 to deploy KVM to digitalOcean 5: "
echo "Enter e to exit this menu e: "
echo -e "\n"
echo -e "Enter your selection \c"
read answer
case "$answer" in
	1) 	echo "Enter name for your kvm :"
		read name
		./virt-install-centos $name ;;
	2) ./certs.sh init ;;
	3) ./php-install.sh ;;
	4) ./symfony-install.sh ;;
	5) ./DigitalOcean-deploy.sh ;;
	e) exit ;;
esac
done