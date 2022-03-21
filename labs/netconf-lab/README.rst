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

Create DHCP service for public switch
*************************************

::

  cat << EOF > /etc/public-switch-dnsmasq.conf
  interface=public-switch
  port=0
  log-dhcp
  dhcp-range=192.168.24.100,192.168.24.200,255.255.255.0,10m
  dhcp-option=option:router,192.168.24.1
  dhcp-option=6,192.168.254.1
  dhcp-host=22:57:f8:dd:fe:aa,nexus.example.com,192.168.24.21
  dhcp-host=22:57:f8:dd:fe:ab,veos.example.com,192.168.24.22
  dhcp-host=22:57:f8:dd:fe:ac,cumulus.example.com,192.168.24.23
  dhcp-host=22:57:f8:dd:fe:ad,vqfx-re.example.com,192.168.24.24
  dhcp-host=22:57:f8:dd:fe:ae,vqfx-pfe.example.com,192.168.24.25
  dhcp-host=22:57:f8:dd:fe:cc,openstack.example.com,192.168.24.40
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

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-cu000
  DEVICE=cu000
  NAME=cu000
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-cu001
  DEVICE=cu001
  NAME=cu001
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-cu002
  DEVICE=cu002
  NAME=cu002
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-cu003
  DEVICE=cu003
  NAME=cu003
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-cu004
  DEVICE=cu004
  NAME=cu004
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-cu005
  DEVICE=cu005
  NAME=cu005
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-cu006
  DEVICE=cu006
  NAME=cu006
  MTU=9000
  ONBOOT=yes
  TYPE=bridge
  BRIDGING_OPTS=ageing_time=0
  BOOTPROTO=none
  EOF

  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-cu007
  DEVICE=cu007
  NAME=cu007
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

  echo 0x4000 > /sys/class/net/cu000/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/cu001/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/cu002/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/cu003/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/cu004/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/cu005/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/cu006/bridge/group_fwd_mask
  echo 0x4000 > /sys/class/net/cu007/bridge/group_fwd_mask

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

  ssh-key-gen -f /root/ml2netconf

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
    192.168.24.30

**Passwd**: Juniper

::

  ssh 192.168.24.30
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
  set system login use netconf full-name "ML2 Netconf"
  set system login use netconf class operator
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
      --network bridge=cu000,model=virtio \
      --network bridge=cu001,model=virtio \
      --network bridge=cu002,model=virtio \
      --network bridge=cu003,model=virtio \
      --network bridge=cu004,model=virtio \
      --network bridge=cu005,model=virtio \
      --network bridge=cu006,model=virtio \
      --network bridge=cu007,model=virtio 


