#! bin/bash


echo "Start installing Code Verifier libraries"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -q git make
cd /tmp/
rm -rf scipy-verifier
git clone https://github.com/dinoboff/scipy-verifier.git
cd scipy-verifier
sudo DEBIAN_FRONTEND=noninteractive make deps
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo locale-gen en_US.UTF-8
sudo make clean install
