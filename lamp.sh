#!/bin/bash
#===============================================================================
#
#          FILE: lamp.sh
#
#         USAGE: ./lamp.sh
#
#  DESCRIPTION: This will install lampstack on Debian and Redhat Distro v6 and less 
#                
#       OPTIONS: No option is required
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ruudgong
#  ORGANIZATION: 
#       CREATED: 09/05/2016 
#      REVISION: 02
#===============================================================================

if [ "`lsb_release -is`" == "Ubuntu" ] || [ "`lsb_release -is`" == "Debian" ]
then
    sudo apt-get -y install mysql-server mysql-client mysql-workbench libmysqld-dev;
    sudo apt-get -y install apache2 php5 libapache2-mod-php5 php5-mcrypt phpmyadmin;
    sudo chmod 777 -R /var/www/;
    sudo printf "<?php\nphpinfo();\n?>" > /var/www/html/info.php;
    sudo service apache2 restart;

elif [ "`lsb_release -is`" == "CentOS" ] || [ "`lsb_release -is`" == "RedHat" ]
then
    sudo yum -y install httpd mysql-server mysql-devel php php-mysql php-fpm;
    sudo yum -y install epel-release phpmyadmin rpm-build redhat-rpm-config;
    sudo yum -y install mysql-community-release-el7-5.noarch.rpm proj;
    sudo yum -y install tinyxml libzip mysql-workbench-community;
    sudo chmod 777 -R /var/www/;
    sudo printf "<?php\nphpinfo();\n?>" > /var/www/html/info.php;
    sudo service mysqld restart;
    sudo service httpd restart;
    sudo chkconfig httpd on;
    sudo chkconfig mysqld on;

else
    echo "Unsupported Operating System OS";
fi
