#!/bin/bash


#get vars
IP=$(cat ip.var | grep "")

#Setting ssh connection
ssh -i centos -t centos@$IP << EOF
	#switch user to su
sudo su
rpm -Uvh https://mirror.webtatic.com/yum/el7/epel-release.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum install -y php56w php56w-opcache php56w-xml php56w-mcrypt php56w-gd php56w-devel php56w-mysql php56w-intl php56w-mbstring php56w-posix
cat > /etc/yum.repos.d/MariaDB.repo <<EOL
# MariaDB 10.1 CentOS repository list - created 2016-05-02 06:24 UTC
# http://mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOL

sudo yum install -y MariaDB-server MariaDB-client wget 

# Enable Apache to load on startup and start it:
sudo systemctl start httpd.service
sudo systemctl enable httpd.service

# Enable MariaDB to load on startup and start it:
sudo systemctl enable mariadb
sudo systemctl start mariadb

# Allow Apache to connect to DB:
sudo setsebool -P httpd_can_network_connect=1
sudo setsebool -P httpd_can_network_connect_db=1

# Allow Apache to write to directory:
chcon -R -t httpd_sys_content_t /var/www
#chcon -R -t httpd_sys_content_t /var/www/docudex
wget http://dl.fedoraproject.org/pub/epel/6/i386//rpl-1.5.5-3.el6.noarch.rpm
rpm -i rpl-1.5.5-3.el6.noarch.rpm
rpl ";date.timezone =" "date.timezone="Europe/Paris"" /etc/php.ini
EOF