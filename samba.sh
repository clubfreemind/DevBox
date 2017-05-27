#!/bin/bash
#get vars
IP=$(cat ip.var | grep "")
CONFIG="[global]
workgroup = WORKGROUP
server string = Samba Server %v
netbios name = centos
security = user
map to guest = bad user
dns proxy = no
#============================ Share Definitions ============================== 
[Anonymous]
path = /home/centos
valid users = samba
browsable = yes
writable = yes
guest ok = yes
read only = no"
pass="root"

#Setting ssh connection
ssh -i centos -t centos@$IP << EOF
	#switch user to su
    sudo su
    echo "Creating new user for samba"
    useradd samba
    echo $pass | passwd samba --stdin
    yum install -y samba samba-common samba-client cups-lib system-config-samba
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
#mkdir /home/centos/shared
echo "$CONFIG" > smb.conf
cp smb.conf /etc/samba/smb.conf
systemctl enable smb.service
systemctl enable nmb.service
systemctl restart smb.service
systemctl restart nmb.service
    echo -e "$pass\n$pass" | smbpasswd -s -a samba
    chmod -R 777 /home/centos/
chown -R nobody:nobody /home/centos/
chcon -t samba_share_t /home/centos/
exit
    echo "done."
EOF
echo "mounting project directory at /mnt/share on host system !"
mount -t cifs -o rw,username=samba,password=root //$IP/Anonymous /mnt/share