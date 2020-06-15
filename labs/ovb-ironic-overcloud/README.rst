vb-ipv4-routed lab
===================

Set up OVB environment
----------------------

::

  mkdir ~/ovb-ironic-overcloud
  virtualenv ~/ovb-ironic-overcloud
  source ~/ovb-ironic-overcloud/bin/activate
  git clone https://opendev.org/openstack/openstack-virtual-baremetal.git ~/ovb-ironic-overcloud/openstack-virtual-baremetal
  pip install ~/ovb-ironic-overcloud/openstack-virtual-baremetal
  pip install python-openstackclient
  pip install ansible
  git clone https://github.com/hjensas/homelab.git ~/ovb-ironic-overcloud/homelab
  cp ~/ovb-ironic-overcloud/homelab/labs/ovb-ironic-overcloud/ovb/* ~/ovb-ironic-overcloud/openstack-virtual-baremetal/

Set up OVB routed-networks lab
------------------------------

The OVB environment files expect:
 - A pre-existing private network to be available in the tenant.
   This network also need to be connected to a router with a connection
   to the external network.
 - A key, key_name: default must exist

  .. NOTE:: Source the cloud RC file first

::

  cd ~/ovb-ironic-overcloud/openstack-virtual-baremetal/
  export OS_CLOUD=homelab
  bash ~/ovb-ironic-overcloud/openstack-virtual-baremetal/deploy_ovb.sh

Deploy the overcloud
--------------------

Log into the ovb undercloud node, user: centos.

To deploy without routed networks first::

  bash ~/overcloud/deploy_overcloud_pre_update.sh

Deploy (or update) with routed networks::

  bash ~/overcloud/deploy_overcloud.sh


Overcloud post deploy config
----------------------------

::

  sudo dnf install wget
  wget https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2

::

  openstack network create --provider-network-type flat --provider-physical-network baremetal_a --share baremetal_a
  openstack network create --provider-network-type flat --provider-physical-network baremetal_b --share baremetal_b
  openstack subnet create --network baremetal_a --subnet-range 172.19.0.0/24 --ip-version 4 --gateway 172.19.0.254 --allocation-pool start=172.19.0.100,end=172.19.0.199 --dhcp baremetal_a_subnet
  openstack subnet create --network baremetal_b --subnet-range 172.19.1.0/24 --ip-version 4 --gateway 172.19.1.254 --allocation-pool start=172.19.1.100,end=172.19.1.199 --dhcp baremetal_b_subnet
  openstack flavor create --disk 40 --public --ram 4096 --vcpus 1 --rxtx-factor 1.0 --property resources:CUSTOM_BAREMETAL='1' --property resources:DISK_GB='0' --property resources:MEMORY_MB='0' --property resources:VCPU='0' baremetal
  openstack image create --container-format aki --disk-format aki  --public --file ./tftpboot/agent.kernel bm-deploy-kernel
  openstack image create --container-format aki --disk-format aki  --public --file ./images/ironic-python-agent.kernel bm-deploy-kernel
  openstack image create --container-format aki --disk-format aki  --public --file ./images/ironic-python-agent.initramfs bm-deploy-ramdisk
  openstack image create --file CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2 --public --container-format bare --disk-format qcow2 centos8


Run Tempest tests on the overcloud
----------------------------------

::

  source overcloudrc

::

  openstack role create --or-show Member
  openstack role create --or-show creator

::

  openstack network create public \
    --external \
    --provider-network-type flat \
    --provider-physical-network datacentre

::

  openstack subnet create ext-subnet \
    --subnet-range 10.0.0.0/24 \
    --allocation-pool start=10.0.0.100,end=10.0.0.200 \
    --no-dhcp \
    --gateway 10.0.0.254 \
    --network public

::

  sudo yum -y install openstack-tempest

::

  tempest init tempest_workspace

::

  cd tempest_workspace

::

  discover-tempest-config --out etc/tempest.conf \
  --deployer-input ~/tempest-deployer-input.conf \
  --network-id $(openstack network show public -f value -c id) \
  --image http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img \
  --debug \
  --remove network-feature-enabled.api_extensions=dvr \
  --create \
    auth.use_dynamic_credentials true \
    auth.tempest_roles Member \
    network-feature-enabled.port_security true \
    compute-feature-enabled.attach_encrypted_volume False \
    network.tenant_network_cidr 192.168.0.0/24 \
    compute.build_timeout 500 \
    volume-feature-enabled.api_v1 False \
    validation.image_ssh_user cirros \
    validation.ssh_user cirros \
    network.build_timeout 500 \
    volume.build_timeout 500 \
    object-storage-feature-enabled.discoverability False \
    service_available.swift False \
    compute-feature-enabled.console_output true \
    orchestration.stack_owner_role Member

::

  tempest cleanup --init-saved-state

::

  tempest run --smoke
