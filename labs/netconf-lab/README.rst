Netconf Lab
===========

Install packages for virtualization host etc
--------------------------------------------

::

  dnf update -y
  dnf install -y \
    guestfs-tools libguestfs-tools tmux vim-enhanced \
    virt-install telnet bridge-utils libvirt firewalld

Enable and start libvirtd
-------------------------

::

  systemctl enable libvirtd.service
  systemctl restart libvirtd.service

 
Create ssh keypair
------------------

::
  
  ssh-keygen


Create vbmc user
----------------

::

  useradd vbmc
  usermod -a -G libvirt vbmc
  passwd vbmc


Enable routing
--------------

::

  echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/router.conf
  sysctl -w net.ipv4.ip_forward=1

Create a firewall zones, and rules
----------------------------------

::

  systemctl enable firewalld.service
  systemctl start firewalld.service
  firewall-cmd --new-zone=public-switch --permanent
  firewall-cmd --zone=public-switch --add-forward --permanent
  firewall-cmd --zone=public-switch --add-masquerade --permanent
  firewall-cmd --zone=public-switch --add-service dhcp --permanent
  firewall-cmd --zone=public-switch --add-service ssh --permanent

  nmcli con mod eth0 connection.zone public-switch
  systemctl restart firewalld

Create virtual networks
-----------------------

Create a public switch on host
******************************

::

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-public-switch
  DEVICE="public-switch"
  NAME="public-switch"
  ZONE=public-switch
  ONBOOT="yes"
  TYPE=bridge
  BOOTPROTO=none
  DEFROUTE=yes
  IPV6INIT=no
  IPADDR=192.168.24.1
  NETMASK=255.255.255.0
  EOF

  cat << EOF > /etc/public-switch-dnsmasq.conf
  interface=public-switch
  port=0
  log-dhcp
  dhcp-range=192.168.24.100,192.168.24.200,255.255.255.0,10m
  dhcp-option=option:router,192.168.24.1
  dhcp-option=6,192.168.254.1
  dhcp-host=22:57:f8:dd:fe:aa,nexus.example.com,192.168.24.21
  dhcp-host=22:57:f8:dd:fe:ab,veos.example.com,192.168.24.22
  dhcp-host=22:57:f8:dd:fe:cc,openstack.example.com,192.168.24.23
  EOF

Create bridges for Cisco Nexus
******************************

::

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-nx000
  DEVICE=nx000
  NAME=nx000
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF
  
  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-nx001
  DEVICE=nx001
  NAME=nx001
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF
  
  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-nx002
  DEVICE=nx002
  NAME=nx002
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF
  
  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-nx003
  DEVICE=nx003
  NAME=nx003
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-nx004
  DEVICE=nx004
  NAME=nx004
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-nx005
  DEVICE=nx005
  NAME=nx005
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-nx006
  DEVICE=nx006
  NAME=nx006
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-nx007
  DEVICE=nx007
  NAME=nx007
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

Create bridges for Arista vEOS
------------------------------

::

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-000
  DEVICE=veos000
  NAME=veos000
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF
  
  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-veos001
  DEVICE=veos001
  NAME=veos001
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF
  
  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-veos002
  DEVICE=veos002
  NAME=veos002
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF
  
  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-veos003
  DEVICE=veos003
  NAME=veos003
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-veos004
  DEVICE=veos004
  NAME=veos004
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-veos005
  DEVICE=veos005
  NAME=veos005
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-veos006
  DEVICE=veos006
  NAME=veos006
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-veos007
  DEVICE=veos007
  NAME=veos007
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

Create Bridges for Juniper vQFX
*******************************

::

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-qfx-int
  DEVICE=qfx-int
  NAME=qfx-int
  ZONE=vqfx-bridges
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF
    
  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-vqfx000
  DEVICE=vqfx000
  NAME=vqfx000
  ZONE=vqfx-bridges
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF
  
  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-vqfx001
  DEVICE=vqfx001
  NAME=vqfx001
  ZONE=vqfx-bridges
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF
  
  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-vqfx002
  DEVICE=vqfx002
  NAME=vqfx002
  ZONE=vqfx-bridges
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF
  
  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-vqfx003
  DEVICE=vqfx003
  NAME=vqfx003
  ZONE=vqfx-bridges
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-vqfx004
  DEVICE=vqfx004
  NAME=vqfx004
  ZONE=vqfx-bridges
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-vqfx005
  DEVICE=vqfx005
  NAME=vqfx005
  ZONE=vqfx-bridges
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-vqfx006
  DEVICE=vqfx006
  NAME=vqfx006
  ZONE=vqfx-bridges
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-vqfx006
  DEVICE=vqfx006
  NAME=vqfx006
  ZONE=vqfx-bridges
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

Restart networking service
--------------------------

systemctl restart NetworkManager.service

