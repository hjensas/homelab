Netconf Lab
===========

Install packages for virtualization host etc
--------------------------------------------

::

  dnf update -y
  dnf install -y \
    guestfs-tools libguestfs-tools tmux vim-enhanced \
    virt-install telnet bridge-utils libvirt firewalld \
    NetworkManager-initscripts-ifcfg-rh

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
  firewall-cmd --zone=public-switch --add-service tftp --permanent
  firewall-cmd --zone=public-switch --add-service ssh --permanent

  nmcli con mod "System eth0" connection.zone public-switch
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

Create TFTP directory
*********************

::

  mkdir /var/lib/tftpboot

Create Cisco Nexus POAP script
******************************

::

  cat << EOF > /var/lib/tftpboot/nexus.py
  
  EOF

Create DHCP service for public switch
*************************************

::

  cat << EOF > /etc/public-switch-dnsmasq.conf
  interface=public-switch
  port=0
  log-dhcp
  dhcp-option=26,1462
  dhcp-range=192.168.24.100,192.168.24.200,255.255.255.0,2h
  dhcp-option=option:router,192.168.24.1
  dhcp-option=6,192.168.254.1
  dhcp-host=22:57:f8:dd:fe:aa,set:nexus,nexus.example.com,192.168.24.21
  dhcp-host=22:57:f8:dd:fe:ab,set:veos,veos.example.com,192.168.24.22
  dhcp-host=22:57:f8:dd:fe:ac,cumulus.example.com,192.168.24.23
  dhcp-host=22:57:f8:dd:fe:ad,vqfx-re.example.com,192.168.24.24
  dhcp-host=22:57:f8:dd:fe:ae,vqfx-pfe.example.com,192.168.24.25
  dhcp-host=22:57:f8:dd:fe:cc,openstack.example.com,192.168.24.40
  dhcp-option=tag:nexus,66,"192.168.24.1"
  dhcp-option=tag:nexux,67,poap.py
  enable-tftp
  tftp-root=/var/lib/tftpboot
  EOF

::

  cat << EOF > /etc/systemd/system/public-switch-dnsmasq.service
  [Unit]
  Description=Public switch DHCP server
  After=network.target
  
  [Service]
  ExecStart=/usr/sbin/dnsmasq -k -C /etc/public-switch-dnsmasq.conf
  
  [Install]
  WantedBy=multi-user.target
  EOF

::

  systemctl enable public-switch-dnsmasq.service
  systemctl start public-switch-dnsmasq.service

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
******************************

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

Creat Bridges for Cumulus VX
****************************

::

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-swp1
  DEVICE=swp1
  NAME=swp1
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-swp2
  DEVICE=swp2
  NAME=swp2
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-swp3
  DEVICE=swp3
  NAME=swp3
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-swp4
  DEVICE=swp4
  NAME=swp4
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-swp5
  DEVICE=swp5
  NAME=swp5
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-swp6
  DEVICE=swp6
  NAME=swp6
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-swp7
  DEVICE=swp7
  NAME=swp7
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-swp8
  DEVICE=swp8
  NAME=swp8
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
**************************

::

  systemctl restart NetworkManager.service

Set group_fwd_mask soo LLDP is forwarded
****************************************

::

  echo 0x4000 > /sys/class/net/vqfx000/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/vqfx001/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/vqfx002/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/vqfx003/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/vqfx004/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/vqfx005/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/vqfx006/bridge/group_fwd_mask
  
  echo 0x4000 > /sys/class/net/veos000/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/veos001/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/veos002/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/veos003/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/veos004/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/veos005/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/veos006/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/veos007/bridge/group_fwd_mask

  echo 0x4000 > /sys/class/net/nx000/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/nx001/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/nx002/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/nx003/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/nx004/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/nx005/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/nx006/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/nx007/bridge/group_fwd_mask

  echo 0x4000 > /sys/class/net/swp1/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/swp2/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/swp3/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/swp4/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/swp5/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/swp6/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/swp7/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/swp8/bridge/group_fwd_mask

Configure libvirt networking
----------------------------

::

  virsh net-destroy default
  virsh net-undefine default
  
  # Libvirt bridged network
  cat << EOF > public.xml
  <network>
      <name>public</name>
      <forward mode="bridge" />
      <bridge name="public-switch" />
  </network>
  EOF
  virsh net-define public.xml
  sudo virsh net-start public
  sudo virsh net-autostart public

Create virtual switches
-----------------------

Create a SSH keypari for netconf
********************************

::

  ssh-keygen -f /root/ml2netconf

Cisco Nexus virtual switch
**************************

Create the VM instance
......................

::

  cp /home/fedora/virtual-switch-images/nexus9500v64.10.2.2.F.qcow2 /var/lib/libvirt/images/nexus.qcow2
  qemu-img resize /var/lib/libvirt/images/nexus.qcow2 +10G

  virt-install \
    --name nexus \
    --boot uefi \
    --os-variant generic \
    --noautoconsole \
    --graphics vnc \
    --memory 12288 \
    --vcpus=2 \
    --import \
    --disk /var/lib/libvirt/images/nexus.qcow2,format=qcow2,bus=sata \
    --serial tcp,host=0.0.0.0:2251,mode=bind,protocol=telnet \
    --network network=public,model=e1000,mac.address=22:57:f8:dd:fe:aa \
    --network bridge=nx000,model=e1000 \
    --network bridge=nx001,model=e1000 \
    --network bridge=nx002,model=e1000 \
    --network bridge=nx003,model=e1000 \
    --network bridge=nx004,model=e1000 \
    --network bridge=nx005,model=e1000 \
    --network bridge=nx006,model=e1000 \
    --network bridge=nx007,model=e1000

Cisco initial setup using telnet
................................

Note
  When ``Abort Power On Auto Provisioning`` - type ``skip`` and use setup
  wizard.

::

  telnet 0.0.0.0 2251
  ## Switch CLI
  configure terminal
  feature lldp
  feature lacp
  interface mgmt 0
  ip address dhcp
  no shut
  exit
  no password strength-check
  username admin password 0 redhat role network-admin
  boot nxos bootflash:///nxos64-cs.10.2.2.F.bin
  copy run start
  exit

Cisco initial setup, (ssh admin@192.168.24.21)
..............................................

::

  configure
  vlan 1000
  name provisioning
  exit                                                                                                                                           
  vlan 1001
  name cleaning
  exit

  vlan 1002
  name rescue
  exit

  vlan 1003
  name inspect
  exit

  vlan 1003
  name inspect
  exit

  vlan 1004-1050
  exit

  interface eth1/1
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1050
  no shut
  exit

  interface eth1/3
  switchport
  switchport mode access
  switchport access vlan 1003
  no shut
  exit

  interface eth1/4
  switchport
  switchport mode access
  switchport access vlan 1003
  no shut
  exit

  copy run start

Cisco enable netconf and enable OpenConfig
..........................................

::

  configure
  feature netconf
  exit
  copy run start
  install activate mtx-openconfig-all

Copy ssh key to switch and create ml2netconf user
.................................................

::

  copy scp://root@192.168.24.1/root/ml2netconf.pub bootflash:ml2netconf.pub source-interface mgmt 0
  configure terminal
  username ml2netconf role network-admin
  username ml2netconf sshkey file bootflash:ml2netconf.pub
  copy run start

Validate Cisco Nexus netconf
............................

::
  
  ssh -i ml2netconf -s ml2netconf@192.168.24.21 -p 830 netconf


Arista vEOS switch
******************

Create the VM instance
......................

::

  qemu-img convert -f vmdk -O qcow2 \
    /home/fedora/virtual-switch-images/Arista/vEOS64-lab-4.27.3F.vmdk \
    /var/lib/libvirt/images/veos.qcow2

  qemu-img resize /var/lib/libvirt/images/veos.qcow2 +10G
  virt-install \
    --name veos \
    --os-variant generic \
    --noautoconsole \
    --graphics vnc \
    --memory 12288 \
    --vcpus=2 \
    --import \
    --disk /var/lib/libvirt/images/veos.qcow2,format=qcow2,bus=sata \
    --serial tcp,host=0.0.0.0:2252,mode=bind,protocol=telnet \
    --network network=public,model=e1000,mac.address=22:57:f8:dd:fe:ab \
    --network bridge=veos000,model=e1000 \
    --network bridge=veos001,model=e1000 \
    --network bridge=veos002,model=e1000 \
    --network bridge=veos003,model=e1000 \
    --network bridge=veos004,model=e1000 \
    --network bridge=veos005,model=e1000 \
    --network bridge=veos006,model=e1000 \
    --network bridge=veos007,model=e1000

Arista vEOS initial setup using telnet
......................................

::

  telnet 0.0.0.0 2252
  Login: admin
  > zerotouch disable

  Login: admin
  > 
  enable
  configure
  vrf instance management
  interface management 1
  vrf management
  ip address dhcp
  exit
  username admin secret 0 redhat
  copy running-config startup-config


Arista vEOS initial setup, (ssh admin@192.168.24.22)
....................................................

::

  enable
  configure
  username ml2netconf role network-operator nopassword
  username ml2netconf ssh-key <$SSH_PUBLIC_KEY>
  exit
  copy running-config startup-config
  
  enable
  configure
  lldp run
  exit
  copy run start
  
  enable
  configure
  management api netconf
  transport ssh default
  vrf management
  exit
  exit
  copy run startup-config
  
  # Below is a copy of the default-control-plane-acl with netconf (830) added at the end
  ip access-list netconf
          10 permit icmp any any
          20 permit ip any any tracked
          30 permit udp any any eq bfd ttl eq 255
          40 permit udp any any eq bfd-echo ttl eq 254
          50 permit udp any any eq multihop-bfd micro-bfd sbfd
          60 permit udp any eq sbfd any eq sbfd-initiator
          70 permit ospf any any
          80 permit tcp any any eq ssh telnet www snmp bgp https msdp ldp netconf-ssh gnmi
          90 permit udp any any eq bootps bootpc snmp rip ntp ldp ptp-event ptp-general
          100 permit tcp any any eq mlag ttl eq 255
          110 permit udp any any eq mlag ttl eq 255
          120 permit vrrp any any
          130 permit ahp any any
          140 permit pim any any
          150 permit igmp any any
          160 permit tcp any any range 5900 5910
          170 permit tcp any any range 50000 50100
          180 permit udp any any range 51000 51100
          190 permit tcp any any eq 3333
          200 permit tcp any any eq nat ttl eq 255
          210 permit tcp any eq bgp any
          220 permit rsvp any any
          230 permit tcp any any eq 6040
          240 permit tcp any any eq 5541 ttl eq 255
          250 permit tcp any any eq 5542 ttl eq 255
          260 permit tcp any any eq 9559
          279 permit tcp any any eq 830
  exit
  system control-plane
  ip access-group netconf vrf management in
  exit

  copy running-config startup-config

  # All ports must be set as "switchports"
  enable
  configure
  interface ethernet 1-8
  switchport
  exit
  exit
  copy running-config startup-config
  
  # Set up vlans
  enable
  configure
  vlan 1000
  name provision
  exit
  vlan 1001
  name cleaning
  exit
  vlan 1002
  name rescuring
  exit
  vlan 1003
  name inspection
  exit
  vlan 1004-1050
  state active
  name tenant
  exit
  copy running-config startup-config

  reload

Validate Arista vEOS netconf
............................

::
  
  ssh -i ml2netconf -s ml2netconf@192.168.24.22 -p 830 netconf

Juniper vQFX switch
*******************

Create the VM instance for RE
.............................

::

  cp /home/fedora/virtual-switch-images/Juniper/vqfx-20.2R1.10-re-qemu.qcow2 \
     /var/lib/libvirt/images/vqfx-re.img

  virt-install \
      --name vqfx-re \
      --os-variant freebsd10.0 \
      --noautoconsole \
      --graphics vnc \
      --memory 2048 \
      --vcpus=2 \
      --import \
      --disk /var/lib/libvirt/images/vqfx-re.img,bus=ide,format=raw \
      --network network=public,model=e1000,mac.address=22:57:f8:dd:fe:ad \
      --network bridge=qfx-int,model=e1000 \
      --network bridge=qfx-int,model=e1000 \
      --network bridge=vqfx000,model=e1000 \
      --network bridge=vqfx001,model=e1000 \
      --network bridge=vqfx002,model=e1000 \
      --network bridge=vqfx003,model=e1000 \
      --network bridge=vqfx004,model=e1000 \
      --network bridge=vqfx005,model=e1000 \
      --network bridge=vqfx006,model=e1000

Create the VM instance for PFE
..............................

::

  cp /home/fedora/virtual-switch-images/Juniper/vqfx-20.2R1-2019010209-pfe-qemu.qcow \
     /var/lib/libvirt/images/vqfx-pfe.img

  virt-install \
      --name vqfx-pfe \
      --os-variant freebsd10.0 \
      --noautoconsole \
      --graphics vnc \
      --memory 2048 \
      --vcpus=2 \
      --import \
      --disk /var/lib/libvirt/images/vqfx-pfe.img,bus=ide,format=raw \
      --network network=public,model=e1000,mac.address=22:57:f8:dd:fe:ae \
      --network bridge=qfx-int,model=e1000 \
      --network bridge=qfx-int,model=e1000


Juniper vQFX initial setup
..........................

::

  ssh-copy-id \
    -o PreferredAuthentications=password \
    -o UserKnownHostsFile=/dev/null \
    -o StrictHostKeyChecking=no \
    192.168.24.24

**Passwd**: Juniper

::

  ssh 192.168.24.24
  cli
  configure
  deactivate system syslog user *
  set interfaces em1 unit 0 family inet address 169.254.0.2/24
  commit
  exit
  restart chassis-control
  exit
  exit
  
Create ml2netcon user and add authentication key
................................................

::
  
  cli
  config
  set system login user netconf
  set system login user netconf full-name "ML2 Netconf"
  set system login user netconf class super-user
  set system login user netconf authentication ssh-rsai "<$SSH_PUB_KEY>"
  set system schema openconfig unhide
  set system services netconf rfc-compliant
  commit



Note
  Juniper vQFX-re and vQFX-pfe need time to sync ...

::

  cli
  configure
  set protocols lldp interface all
  commit
  exit
  
  cli
  configure
  delete interfaces xe-0/0/1 unit 0 family inet
  delete interfaces xe-0/0/2 unit 0 family inet
  delete interfaces xe-0/0/3 unit 0 family inet
  delete interfaces xe-0/0/4 unit 0 family inet
  delete interfaces xe-0/0/5 unit 0 family inet
  delete interfaces xe-0/0/6 unit 0 family inet
  delete interfaces xe-0/0/7 unit 0 family inet
  commit

  set vlans provisioning vlan-id 1000
  set vlans cleaning vlan-id 1001
  set vlans rescue vlan-id 1002
  set vlans introspection vlan-id 1003
  set vlans tenant vlan-id-list 1004-1050
  set interfaces xe-0/0/0 unit 0 family ethernet-switching interface-mode trunk vlan members all
  commit

  set interfaces xe-0/0/1 unit 0 family ethernet-switching vlan members default
  set interfaces xe-0/0/2 unit 0 family ethernet-switching vlan members default
  set interfaces xe-0/0/3 unit 0 family ethernet-switching vlan members default
  set interfaces xe-0/0/4 unit 0 family ethernet-switching vlan members default
  set interfaces xe-0/0/5 unit 0 family ethernet-switching vlan members default
  set interfaces xe-0/0/6 unit 0 family ethernet-switching vlan members default
  set interfaces xe-0/0/7 unit 0 family ethernet-switching vlan members default
  
  commit
  exit

Note
  OpenConfig capabilities are not listed when connecting to vQFX10K.
  It might just not be supported ... https://github.com/Juniper/vqfx10k-vagrant/issues/46

Cumulus VX switch
*****************

::

  cp /home/fedora/virtual-switch-images/cumulus/cumulus-linux-5.0.1-vx-amd64-qemu.qcow2 \
     /var/lib/libvirt/images/cumulus.qcow2

  virt-install \
      --name cumulus \
      --os-variant generic \
      --noautoconsole \
      --graphics vnc \
      --memory 1024 \
      --vcpus=2 \
      --import \
      --disk /var/lib/libvirt/images/cumulus.qcow2,format=qcow2 \
      --network network=public,model=virtio,mac.address=22:57:f8:dd:fe:ac \
      --network bridge=swp1,model=virtio \
      --network bridge=swp2,model=virtio \
      --network bridge=swp3,model=virtio \
      --network bridge=swp4,model=virtio \
      --network bridge=swp5,model=virtio \
      --network bridge=swp6,model=virtio \
      --network bridge=swp7,model=virtio \
      --network bridge=swp8,model=virtio 

Note
  Netconf/Openconf support is not currently available, it is mentioned
  in some of their docs that it nvue is the foundation to make it available.
  It might be, if not nvue will likley get python bindings,
  also openapi schema, so possible to generate bindings.


Create some virtual BMs
-----------------------

::

  curl -O https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-20220125.1.x86_64.qcow2

Create BM attached to nexus
***************************

::

  mkdir ~/nexusbm0
  cat << EOF > ~/nexusbm0/ifcfg-eth0
  DEVICE=eth0
  NAME=eth0
  ONBOOT=yes
  TYPE=Ethernet
  BOOTPROTO=none
  IPADDR=192.168.25.10
  NETMASK=255.255.255.0
  EOF

::

  cp ~/CentOS-Stream-GenericCloud-8-*.qcow2 /var/lib/libvirt/images/nexusbm0.qcow2

::

  LIBGUESTFS_BACKEND=direct virt-customize \
    -a /var/lib/libvirt/images/nexusbm0.qcow2 \
    --hostname nexusbm0 \
    --root-password password:redhat \
    --uninstall cloud-init \
    --install lldpd \
    --run-command 'systemctl enable lldpd' \
    --install tcpdump \
    --copy-in ~/nexusbm0/ifcfg-eth0:/etc/sysconfig/network-scripts \
    --delete /etc/sysconfig/network-scripts/ens3 \
    --delete /etc/sysconfig/network-scripts/ens3.1 \
    --selinux-relabel

::

  virt-install \
    --name nexusbm0 \
    --os-variant centos8 \
    --noautoconsole \
    --memory 4096 \
    --vcpus=1 \
    --graphics vnc \
    --import \
    --disk /var/lib/libvirt/images/nexusbm0.qcow2,bus=virtio,format=qcow2 \
    --network bridge=nx003,model=virtio,mac.address=22:57:f8:dd:fe:00


Create BM attached to veos
**************************

::

  mkdir ~/veosbm0
  cat << EOF > ~/veosbm0/ifcfg-eth0
  DEVICE=eth0
  NAME=eth0
  ONBOOT=yes
  TYPE=Ethernet
  BOOTPROTO=none
  IPADDR=192.168.25.20
  NETMASK=255.255.255.0
  EOF

::

  cp ~/CentOS-Stream-GenericCloud-8-*.qcow2 /var/lib/libvirt/images/veosbm0.qcow2

::

  LIBGUESTFS_BACKEND=direct virt-customize \
    -a /var/lib/libvirt/images/veosbm0.qcow2 \
    --hostname veosbm0 \
    --root-password password:redhat \
    --uninstall cloud-init \
    --install lldpd \
    --run-command 'systemctl enable lldpd' \
    --install tcpdump \
    --copy-in ~/veosbm0/ifcfg-eth0:/etc/sysconfig/network-scripts \
    --delete /etc/sysconfig/network-scripts/ens3 \
    --delete /etc/sysconfig/network-scripts/ens3.1 \
    --selinux-relabel

::

  virt-install \
    --name veosbm0 \
    --os-variant centos8 \
    --noautoconsole \
    --memory 4096 \
    --vcpus=1 \
    --graphics vnc \
    --import \
    --disk /var/lib/libvirt/images/veosbm0.qcow2,bus=virtio,format=qcow2 \
    --network bridge=veos003,model=virtio,mac.address=22:57:f8:dd:fe:10

Install devstack
----------------

::

  curl -O https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img

  cp ~/focal-server-cloudimg-amd64.img /var/lib/libvirt/images/openstack.raw
  qemu-img resize /var/lib/libvirt/images/openstack.raw +15G

  # Set root password in server image and hostname
  LIBGUESTFS_BACKEND=direct virt-customize \
  -a /var/lib/libvirt/images/openstack.raw \
  --hostname openstack \
  --root-password password:redhat \
  --run-command 'netplan set ethernets.enp1s0.dhcp4=true' \
  --run-command 'dpkg-reconfigure openssh-server' \
  --ssh-inject root:file:/root/.ssh/id_rsa.pub

  virt-install \
    --name openstack \
    --os-variant ubuntu20.04 \
    --noautoconsole \
    --memory 8192 \
    --vcpus=2 \
    --graphics vnc \
    --import \
    --disk /var/lib/libvirt/images/openstack.raw,bus=virtio,format=qcow2 \
    --network network=public,model=virtio,mac.address=22:57:f8:dd:fe:cc \
    --network bridge=nx001,model=virtio \
    --network bridge=nx002,model=virtio

SSH to the devstack VM
**********************

::

  ssh root@192.168.24.40

  growpart /dev/vda 1
  resize2fs /dev/vda1
  ip link set mtu 1442 enp1s0
  apt update

  apt upgrade -y
  apt install git tmux lldpd openvswitch-switch crudini -y
  echo "configure system hostname 'openstack.example.com'" > /etc/lldpd.d/lldp.conf
  systemctl enable lldpd.service
  systemctl start lldpd.service

Create network bridge dataplane (run as root, sudo fails 
********************************************************

::

  cat << EOF > /etc/netplan/80-dataplane-bridge.yaml
  network:
    version: 2
    renderer: networkd
    ethernets:
      enp2s0:
        dhcp4: no
      enp3s0:
       dhcp4: no
       addresses: [192.168.29.1/24]
    bridges:
      br-dataplane:
        openvswitch: {}
        interfaces:
        - enp2s0
  EOF
  sudo netplan apply

Devstack setup
**************

::

  useradd -s /bin/bash -d /opt/stack -m stack
  echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  sudo su - stack
  ssh-keygen
  ssh-copy-id vbmc@192.168.24.1

  git clone https://opendev.org/openstack/devstack
  # Sync networking-baremetal repo
  git clone https://opendev.org/openstack/networking-baremetal
  rsync -av hjensas@192.168.254.29:/home/hjensas/code/networking-baremetal/* networking-baremetal/

Devstack conf
.............

::

  [[local|localrc]]
  disable_all_services
  enable_service placement-api
  enable_service mysql
  enable_service tempest
  enable_service q-agt
  enable_service n-cpu
  disable_service horizon
  enable_service etcd3
  disable_service neutron-metering
  enable_service n-cond
  disable_service c-api
  enable_service q-metering
  enable_service s-object
  enable_service n-api-meta
  enable_service q-svc
  disable_service neutron-api
  enable_service tls-proxy
  enable_service key
  disable_service c-bak
  disable_service neutron-l3
  disable_service c-sch
  enable_service q-l3
  disable_service neutron-agent
  disable_service cinder
  disable_service neutron-metadata-agent
  enable_service rabbit
  disable_service neutron-dhcp
  enable_service dstat
  enable_service s-account
  enable_service s-container
  enable_service ir-neutronagt
  enable_service n-novnc
  enable_service n-api
  enable_service generic_switch
  enable_service s-proxy
  enable_service n-sch
  enable_service q-meta
  enable_service q-dhcp
  enable_service g-api
  disable_service c-vol
  enable_service networking_baremetal
  
  ADMIN_PASSWORD="secretadmin"
  BUILD_TIMEOUT="2400"
  DATABASE_PASSWORD="secretdatabase"
  DEBUG_LIBVIRT_COREDUMPS="True"
  DEFAULT_INSTANCE_TYPE="baremetal"
  EBTABLES_RACE_FIX="True"
  ENABLE_TENANT_VLANS="True"
  FIXED_RANGE="172.24.6.0/24"
  FLOATING_RANGE="172.24.5.0/24"
  FORCE_CONFIG_DRIVE="False"
  HOST_IP="192.168.29.1"
  IPV4_ADDRS_SAFE_TO_USE="172.24.6.0/24"
  IRONIC_AUTOMATED_CLEAN_ENABLED="False"
  IRONIC_BAREMETAL_BASIC_OPS="True"
  IRONIC_BUILD_DEPLOY_RAMDISK="False"
  IRONIC_CALLBACK_TIMEOUT="700"
  IRONIC_DEFAULT_DEPLOY_INTERFACE="direct"
  IRONIC_DEFAULT_RESCUE_INTERFACE=""
  IRONIC_DEPLOY_DRIVER="ipmi"
  IRONIC_ENABLED_NETWORK_INTERFACES="flat,neutron"
  IRONIC_INSPECTOR_BUILD_RAMDISK="False"
  IRONIC_NETWORK_INTERFACE="neutron"
  IRONIC_PROVISION_NETWORK_NAME="ironic-provision"
  IRONIC_PROVISION_PROVIDER_NETWORK_TYPE="vlan"
  IRONIC_PROVISION_SUBNET_GATEWAY="172.24.7.1"
  IRONIC_PROVISION_SUBNET_PREFIX="172.24.7.0/24"
  IRONIC_PROVISION_ALLOCATION_POOL="start=172.24.7.100,end=172.24.7.150"
  IRONIC_USE_LINK_LOCAL="True"
  IRONIC_USE_NEUTRON_SEGMENTS="True"
  IRONIC_VM_COUNT="0"
  IRONIC_VM_EPHEMERAL_DISK="0"
  IRONIC_VM_LOG_DIR="/opt/stack/ironic-bm-logs"
  IRONIC_VM_SPECS_DISK="4"
  IRONIC_VM_SPECS_RAM="3072"
  LIBVIRT_TYPE="qemu"
  LOGFILE="/opt/stack/logs/devstacklog.txt"
  LOG_COLOR="False"
  NETWORK_GATEWAY="172.24.6.1"
  NOVA_VNC_ENABLED="True"
  NOVNC_FROM_PACKAGE="True"
  OVS_BRIDGE_MAPPINGS="mynetwork:brbm,public:br-ex"
  PHYSICAL_NETWORK="dataplane"
  TENANT_VLAN_RANGE="1000:1500"
  PUBLIC_BRIDGE_MTU="1500"
  PUBLIC_NETWORK_GATEWAY="172.24.5.1"
  PUBLIC_PHYSICAL_NETWORK="public"
  Q_AGENT="openvswitch"
  Q_ML2_TENANT_NETWORK_TYPE="vlan"
  Q_PLUGIN="ml2"
  Q_ML2_PLUGIN_MECHANISM_DRIVERS=openvswitch
  Q_SERVICE_PLUGIN_CLASSES="neutron.services.l3_router.l3_router_plugin.L3RouterPlugin,segments"
  Q_USE_DEBUG_COMMAND="True"
  Q_USE_PROVIDERNET_FOR_PUBLIC="True"
  RABBIT_PASSWORD="secretrabbit"
  SERVICE_HOST="192.168.29.1"
  SERVICE_PASSWORD="secretservice"
  SERVICE_TIMEOUT="90"
  SWIFT_ENABLE_TEMPURLS="True"
  SWIFT_HASH="1234123412341234"
  SWIFT_REPLICAS="1"
  SWIFT_START_ALL_SERVICES="False"
  SWIFT_TEMPURL_KEY="secretkey"
  VERBOSE="True"
  VERBOSE_NO_TIMESTAMP="True"
  VIRT_DRIVER="ironic"
  # LIBS_FROM_GIT=networking-baremetal,ironic-python-agent-builder,swift,nova,virtualbmc,ironic,ironic-python-agent,glance,placement,cinder,requirements,neutron,ironic-tempest-plugin,networking-generic-switch,devstack,keystone
  LIBS_FROM_GIT=networking-baremetal,ironic-python-agent-builder,swift,nova,virtualbmc,ironic,ironic-python-agent,glance,placement,cinder,requirements,neutron,ironic-tempest-plugin,devstack,keystone
  enable_plugin ironic https://opendev.org/openstack/ironic
  enable_plugin ironic-inspector https://opendev.org/openstack/ironic-inspector
  # enable_plugin networking-generic-switch https://opendev.org/openstack/networking-generic-switch
  enable_plugin networking-baremetal https://opendev.org/openstack/networking-baremetal

Post devstack changes
.....................

::

  # Update neutron.conf
  crudini --set --existing /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks public
  crudini --set --existing /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges dataplane:1000:1050
  crudini --set --existing /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings public:br-ex,dataplane:br-dataplane
  
  # Update inspector.conf
  crudini --set --existing /etc/ironic-inspector/inspector.conf DEFAULT timeout 7200
  crudini --set /etc/ironic-inspector/inspector.conf processing processing_hooks "\$default_processing_hooks,extra_hardware,lldp_basic,local_link_connection"
  
  # Update ironic.conf
  crudini --set --existing /etc/ironic/ironic.conf conductor deploy_callback_timeout 7200
  crudini --set --existing /etc/ironic/ironic.conf pxe boot_retry_timeout 7200
  crudini --set --existing /etc/ironic/ironic.conf neutron provisioning_network provision
  crudini --set --existing /etc/ironic/ironic.conf neutron cleaning_network cleaning
  crudini --set --existing /etc/ironic/ironic.conf neutron rescuing_network rescueing
  crudini --set /etc/ironic/ironic.conf neutron inspection_network inspect
  crudini --set --existing /etc/ironic/ironic.conf pxe kernel_append_params "nofb nomodeset systemd.journald.forward_to_console=yes ipa-insecure=1 ipa-collect-lldp=1"
  
  
  # Delete all devstack networks + rotuers + subnets
  openstack network delete ironic-provision
  openstack network delete shared
  openstack router show router1
  openstack router remove subnet router1 <SUBNET_ID>
  openstack router remove subnet router1 <SUBNET_ID>
  openstack router delete router1
  openstack network delete private
  openstack network delete public
  
  
  sudo systemctl restart devstack@*
  
  # Create network resources
  openstack network create provision --share --provider-segment 1000 --provider-network-type vlan --provider-physical-network dataplane
  openstack network create cleaning --share --provider-segment 1001 --provider-network-type vlan --provider-physical-network dataplane
  openstack network create rescueing --share --provider-segment 1002 --provider-network-type vlan --provider-physical-network dataplane
  openstack network create inspect --share --provider-segment 1003 --provider-network-type vlan --provider-physical-network dataplane
  
  openstack subnet create provision --network provision --subnet-range 192.168.30.0/24 --dhcp
  openstack subnet create cleaning --network cleaning --subnet-range 192.168.31.0/24 --dhcp
  openstack subnet create rescueing --network rescueing --subnet-range 192.168.32.0/24 --dhcp
  openstack subnet create inspect --network inspect --subnet-range 192.168.33.0/24 --dhcp
  
  openstack network create public --share --external --provider-network-type flat --provider-physical-network public
  openstack subnet create public --network public --subnet-range 172.24.5.0/24
  
  openstack router create router1
  openstack router set --external-gateway public router1
  openstack router add subnet router1 cleaning
  openstack router add subnet router1 rescueing
  openstack router add subnet router1 provision
  openstack router add subnet router1 inspect
  
  
  # Setup devices config
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini networking_baremetal enabled_devices nexus.example.com,veos.example.com
  
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini nexus.example.com driver netconf-openconfig
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini nexus.example.com switch_info nexus
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini nexus.example.com host 192.168.24.21
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini nexus.example.com username ml2netconf
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini nexus.example.com key_filename /etc/neutron/ssh_keys/ml2netconf
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini nexus.example.com hostkey_verify false
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini nexus.example.com device_params name:nexus
  
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini veos.example.com driver netconf-openconfig
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini veos.example.com switch_info veos
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini veos.example.com host 192.168.24.22
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini veos.example.com username ml2netconf
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini veos.example.com key_filename /etc/neutron/ssh_keys/ml2netconf
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini veos.example.com hostkey_verify false
  crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini veos.example.com device_params name:default
  
  mkdir /etc/neutron/ssh_keys
  cp ml2netconf /etc/neutron/ssh_keys/
  chown stack:stack /etc/neutron/ssh_keys/ml2netconf 
  chown stack:stack /etc/neutron/ssh_keys
  
  sudo systemctl restart devstack@q-svc.service

  ROUTER_GW_IP=$(openstack port list -c "Fixed IP Addresses" -f json --device-owner 'network:router_gateway' | jq --raw-output '.[0]."Fixed IP Addresses"[0].ip_address')
  # Add routes to netwoks on devstack host
  sudo ip route add 192.168.33.0/24 dev br-ex via $ROUTER_GW_IP
  sudo ip route add 192.168.32.0/24 dev br-ex via $ROUTER_GW_IP
  sudo ip route add 192.168.31.0/24 dev br-ex via $ROUTER_GW_IP
  sudo ip route add 192.168.30.0/24 dev br-ex via $ROUTER_GW_IP


Set up VBMC
***********

::

  vbmc add nexusbm0 --port 6230 --libvirt-uri qemu+ssh://vbmc@192.168.24.1/system --password redhat --username admin
  vbmc add veosbm0 --port 6231 --libvirt-uri qemu+ssh://vbmc@192.168.24.1/system --password redhat --username admin
  vbmc start nexusbm0
  vbmc start veosbm0

**Validate BMCs**

::

  ipmitool -I lanplus -U admin -P redhat -H 127.0.0.1 -p 6230 power status
  ipmitool -I lanplus -U admin -P redhat -H 127.0.0.1 -p 6231 power status

Import nodes
************

::

  cat << EOF > ~/ironic_nodes.yaml
  nodes:
  - name: nexusbm0
    driver: ipmi
    driver_info:
      ipmi_address: 127.0.0.1
      ipmi_port: 6230
      ipmi_username: admin
      ipmi_password: redhat
    properties:
      cpus: 1
      cpu_arch: x86_64
      memory_mb: 2048
      local_gb: 10
    ports:
    - address: 22:57:f8:dd:fe:00
      physical_network: dataplane
  - name: veosbm0
    driver: ipmi
    driver_info:
      ipmi_address: 127.0.0.1
      ipmi_port: 6231
      ipmi_username: admin
      ipmi_password: redhat
    properties:
      cpus: 1
      cpu_arch: x86_64
      memory_mb: 2048
      local_gb: 10
    ports:
    - address: 22:57:f8:dd:fe:10
      physical_network: dataplane
  EOF

::

  openstack baremetal create ~/ironic_nodes.yaml
  openstack baremetal node manage nexusbm0
  openstack baremetal node manage veosbm0


Testing notes
-------------

Create/Delete/Update network

::

  openstack network create \
    --provider-network-type vlan \
    --provider-segment 1040 \
    --provider-physical-network dataplane \
    vlan1040
  openstack network set --disable vlan1040
  openstack network set --enable vlan1040
  openstack network set \
    --name vlan1041 \
    --provider-segment 1041 \
    vlan1041
  openstack network delete vlan1041

Some commands to do some simple port testing in python shell

::

  import openstack
  conn = openstack.connect('devstack-admin')
  net_id = conn.network.find_network(name_or_id='test-net').id
  
  nexus_port = conn.network.create_port(name='nexus-test-port', network_id=net_id)
  nexus_binding_profile = {}
  nexus_lli = []
  nexus_lli.append({'port_id': 'eth1/4', 'switch_id': '', 'switch_info': 'nexus'})
  nexus_binding_profile['local_link_information'] = nexus_lli
  nexus_bind_args = {'binding:profile': nexus_binding_profile,
                     'binding:host_id': '7a140743-db18-4ce4-9e9b-6793fbe401a5',
                     'binding:vnic_type': 'baremetal'}
  nexus_unbind_args = {'binding:profile': None,
                       'binding:host_id': None}
  
  conn.network.update_port(nexus_port, **nexus_bind_args)
  conn.network.update_port(nexus_port, **nexus_unbind_args)
  
  
  veos_port = conn.network.create_port(name='veos-test-port', network_id=net_id)
  veos_binding_profile = {}
  veos_lli = []
  veos_lli.append({'port_id': 'Ethernet4', 'switch_id': '', 'switch_info': 'veos'})
  veos_binding_profile['local_link_information'] = veos_lli
  veos_bind_args = {'binding:profile': veos_binding_profile,
                     'binding:host_id': '7a140743-db18-4ce4-9e9b-6793fbe401a5',
                     'binding:vnic_type': 'baremetal'}
  veos_unbind_args = {'binding:profile': None,
                       'binding:host_id': None}
  
  conn.network.update_port(veos_port, **veos_bind_args)
  conn.network.update_port(veos_port, **veos_unbind_args)

Commands for LACP bonds testing in phython shell

::

  import openstack
  conn = openstack.connect('devstack-admin')
  net_id = conn.network.find_network(name_or_id='test-net').id

  nexus_lacp_port = conn.network.create_port(name='nexus-lacp-test-port', network_id=net_id)
  nexus_lacp_binding_profile = {}
  nexus_lacp_lli = nexus_lacp_binding_profile['local_link_information'] = []
  nexus_lacp_lli.append({'port_id': 'eth1/11', 'switch_id': '', 'switch_info': 'nexus'})
  nexus_lacp_lli.append({'port_id': 'eth1/12', 'switch_id': '', 'switch_info': 'nexus'})
  nexus_lgi = nexus_lacp_binding_profile['local_group_information'] = {}
  nexus_lgi['id'] = 'port_group_id'
  nexus_lgi['name'] = 'PortGroup1'
  nexus_lgi['bond_mode'] = '802.3ad'
  nexus_bond_prop = nexus_lgi['bond_properties'] = {}
  nexus_bond_prop['bond_lacp_rate'] = 'fast'
  nexus_bond_prop['bond_min_links'] = 2
  nexus_lacp_bind_args = {'binding:profile': nexus_lacp_binding_profile,
                          'binding:host_id': '7a140743-db18-4ce4-9e9b-6793fbe401a5',
                          'binding:vnic_type': 'baremetal'}
  nexus_lacp_unbind_args = {'binding:profile': None,
                          'binding:host_id': None}
  
  conn.network.update_port(nexus_lacp_port, **nexus_lacp_bind_args)
  conn.network.update_port(nexus_lacp_port, **nexus_lacp_unbind_args)
  
  
  veos_lacp_port = conn.network.create_port(name='veos-lacp-test-port', network_id=net_id)
  veos_lacp_binding_profile = {}
  veos_lacp_lli = veos_lacp_binding_profile['local_link_information'] = []
  veos_lacp_lli.append({'port_id': 'Ethernet7', 'switch_id': '', 'switch_info': 'veos'})
  veos_lacp_lli.append({'port_id': 'Ethernet8', 'switch_id': '', 'switch_info': 'veos'})
  veos_lgi = veos_lacp_binding_profile['local_group_information'] = {}
  veos_lgi['id'] = 'port_group_id'
  veos_lgi['name'] = 'PortGroup1'
  veos_lgi['bond_mode'] = '802.3ad'
  veos_bond_prop = veos_lgi['bond_properties'] = {}
  veos_bond_prop['bond_lacp_rate'] = 'fast'
  veos_bond_prop['bond_min_links'] = 2
  veos_lacp_bind_args = {'binding:profile': veos_lacp_binding_profile,
                         'binding:host_id': '7a140743-db18-4ce4-9e9b-6793fbe401a5',
                         'binding:vnic_type': 'baremetal'}
  veos_lacp_unbind_args = {'binding:profile': None,
                           'binding:host_id': None}
  
  conn.network.update_port(veos_lacp_port, **veos_lacp_bind_args)
  conn.network.update_port(veos_lacp_port, **veos_lacp_unbind_args)

