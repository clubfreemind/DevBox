#!/bin/bash

IP=$(cat ip.var | grep "")
ID=$(cat id.var | grep "")

while true
do
	clear

echo "===================================="
echo "Wrapper Menu"
echo "===================================="
echo "Enter 1 to list active KVM 1: "
echo "Enter 2 to stop a specefic KVM 2: "
echo "Enter 3 to start virsh cli 3: "
echo "Enter exit to exit this menu exit: "
echo -e "\n"
echo -e "Enter your selection : \c"
read answer
case "$answer" in
	1) 	clear
		virsh list 
		read
		;;
	2)  clear
		echo "Enter the KVM Name you want to stop : "
		read name
		virsh destroy $name ;;
	3) virsh ;;
	exit) exit ;;
esac
done