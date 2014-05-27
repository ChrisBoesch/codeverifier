#! bin/bash

echo "Start installing Code Verifier libraries"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y -q git make
cd /tmp/
git clone git://github.com/SingaporeClouds/scipy-verifier.git
cd scipy-verifier
sudo make deps
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo locale-gen en_US.UTF-8
sudo make install
