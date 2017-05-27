#!/bin/bash
#get vars
IP=$(cat ip.var | grep "")
echo "mounting project directory at /mnt/share on host system !"
mount -t cifs -o rw,username=samba,password=root //$IP/Anonymous /mnt/share