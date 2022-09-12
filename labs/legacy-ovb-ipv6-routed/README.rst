ovb-ipv6-routed lab
===================

Set up OVB environment
----------------------

::

  mkdir ~/ovb-ipv6-routed
  virtualenv ~/ovb-ipv6-routed
  source ~/ovb-ipv6-routed/bin/activate
  git clone https://opendev.org/openstack/openstack-virtual-baremetal.git ~/ovb-ipv6-routed/openstack-virtual-baremetal
  pip install ~/ovb-ipv6-routed/openstack-virtual-baremetal
  pip install python-openstackclient
  pip install ansible
  git clone https://github.com/hjensas/homelab.git ~/ovb-ipv6-routed/homelab
  cp ~/ovb-ipv6-routed/homelab/labs/ovb-ipv6-routed/ovb/* ~/ovb-ipv6-routed/openstack-virtual-baremetal/

Set up OVB routed-networks lab
------------------------------

The OVB environment files expect:
 - A pre-existing private network to be available in the tenant.
   This network also need to be connected to a router with a connection
   to the external network.
 - A key, key_name: default must exist

  .. NOTE:: Source the cloud RC file first

::

  cd ~/ovb-ipv6-routed/openstack-virtual-baremetal/
  export OS_CLOUD=homelab
  bash ~/ovb-ipv6-routed/openstack-virtual-baremetal/deploy_ovb.sh

