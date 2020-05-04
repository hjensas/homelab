openstack network create public --external --provider-network-type flat --provider-physical-network datacentre
openstack subnet create public --network public --dhcp --allocation-pool start=192.168.254.150,end=192.168.254.1 --gateway 192.168.254.1 --subnet-range 192.168.254.0/24
