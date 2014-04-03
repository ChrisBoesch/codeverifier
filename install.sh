#! bin/bash

echo "Start installing Code Verifier libraries"
export DEBIAN_FRONTEND=noninteractive
sudo useradd -d /home/verifiers -m verifiers
sudo apt-get -q -y update
sudo apt-get -q -y install openjdk-7-jre openjdk-7-jdk python-scipy python-rpy2 git python-setuptools python-dev build-essential libevent-dev python-gevent r-cran-runit libgnustep-base-dev  gobjc gnustep gnustep-make gnustep-common ruby ant python-pip
sudo apt-get -q -y remove  openjdk-6-jre-lib
sudo easy_install gserver
sudo easy_install tornado
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo locale-gen en_US.UTF-8
#sudo dpkg-reconfigure locales
sudo mkdir /home/server
cd /home/server
#sudo rm /home/server/install_r_libraries
#sudo touch /home/server/install_r_libraries
#sudo chmod 777 /home/server/install_r_libraries
#sudo echo -e "from rpy2.robjects import r\nr(\"install.packages('testthat','/usr/lib/R/site-library/')\")" >> /home/server/install_r_libraries
#sudo python /home/server/install_r_libraries >> /var/log/startupscript.log
sudo git clone git://github.com/SingaporeClouds/scipy-verifier.git
cd scipy-verifier/installation/
sudo ./boot.sh

