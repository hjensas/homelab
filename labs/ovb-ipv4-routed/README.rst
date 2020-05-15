ooo-bp-tripleo-routed-networks-templates-testing
================================================

Set up OVB environment
----------------------

::

  mkdir ~/ovb-lab
  virtualenv ~/ovb-lab
  source ~/ovb-lab/bin/activate
  git clone https://opendev.org/openstack/openstack-virtual-baremetal.git ~/ovb-lab/openstack-virtual-baremetal
  pip install ~/ovb-lab/openstack-virtual-baremetal
  pip install python-openstackclient
  pip install ansible
  git clone https://github.com/hjensas/ooo-bp-tripleo-routed-networks-templates-testing.git ~/ovb-lab/ooo-bp-tripleo-routed-networks-templates-testing
  cp ~/ovb-lab/ooo-bp-tripleo-routed-networks-templates-testing/ovb/* ~/ovb-lab/openstack-virtual-baremetal/

Set up OVB routed-networks lab
------------------------------

The OVB environment files expect:
 - A pre-existing private network to be available in the tenant.
   This network also need to be connected to a router with a connection
   to the external network.
 - A key, key_name: default must exist

  .. NOTE:: Source the cloud RC file first

::

  cd ~/ovb-lab/openstack-virtual-baremetal/
  bash ~/ovb-lab/openstack-virtual-baremetal/deploy_ovb.sh

Run ansible playbook to deploy the undercloud
---------------------------------------------

  .. NOTE:: The playbook also:

              - Build images
              - Uploads images
              - Imports, Introspectes and Provide nodes
              - Creates flavors and adds node capabilities

::

  ansible-playbook -i inventory.ini ~/ovb-lab/ooo-bp-tripleo-routed-networks-templates-testing/playbooks/deploy_undercloud.yaml

Deploy the overcloud
--------------------

Log into the ovb undercloud node, user: centos.

To deploy without routed networks first::

  bash ~/overcloud/deploy_overcloud_pre_update.sh

Deploy (or update) with routed networks::

  bash ~/overcloud/deploy_overcloud.sh

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
