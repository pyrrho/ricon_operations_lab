#! /bin/bash
source /vagrant/bin/provision_helper.sh
echo "* Configuring SSH"
echo "    - Generating Root Keypair"
ssh-keygen -t rsa -C "root@riak.local" -f /root/.ssh/id_rsa -N ""
chmod 600 /root/.ssh/id_rsa* 

cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys 

cp /root/.ssh/id_rsa* /vagrant/data/work

cp /root/.ssh/id_rsa* /home/vagrant/.ssh
chown vagrant /home/vagrant/.ssh/id_rsa*
chmod 600 /home/vagrant/.ssh/id_rsa*

echo "    - Disabling GSSAPIAuthentication"
cp /etc/ssh/ssh_config /etc/ssh/ssh_config.orig
sed 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/ssh_config.orig > /etc/ssh/ssh_config

echo "    - Installing tmux..."
cp /vagrant/data/applications/tmux /usr/local/bin/tmux

echo "    - Installing tmux-cssh..."
cp /vagrant/data/applications/tmux-cssh /usr/local/bin/tmux-cssh

echo "    - Creating ~/.tmux-cssh..."
echo "
others:-u root -sc 192.168.228.12 -sc 192.168.228.13 -sc 192.168.228.14 -sc 192.168.228.15
node1:-u root -sc 192.168.228.11
node2:-u root -sc 192.168.228.12
node3:-u root -sc 192.168.228.13
node4:-u root -sc 192.168.228.14
node5:-u root -sc 192.168.228.15
riak:-cs node1 -cs others
" > ~/.tmux-cssh

cp ~/.tmux-cssh /home/vagrant
chown vagrant /home/vagrant/.tmux-cssh

echo "* Provisioning Sample Applications"
mkdir /home/vagrant/app

echo "    - Installing Inverted Index Application"
cp -r /vagrant/data/repos/riak-inverted-index-demo /home/vagrant/app/riak-inverted-index-demo

echo "    - Configuring Inverted Index Application"
cd app/riak-inverted-index-demo
mv hosts hosts.orig
echo "192.168.228.11:8098
192.168.228.12:8098
192.168.228.13:8098
192.168.228.14:8098
192.168.228.15:8098" >> hosts

echo "    - Installing Load Generator Application"
cp -r /vagrant/data/repos/load_generator /home/vagrant/app/load_generator

chown -R vagrant:vagrant /home/vagrant/app
echo "*** APP Box Provisioning Complete"
