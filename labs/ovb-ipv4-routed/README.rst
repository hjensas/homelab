ovb-ipv4-routed lab
===================

Set up OVB environment
----------------------

::

  export OS_CLOUD=homelab

  export LAB_NAME=ovb-ipv4-routed
  export LAB_DIR=~/$LAB_NAME
  mkdir $LAB_DIR
  git clone https://github.com/hjensas/homelab.git $LAB_DIR/homelab
  export LAB_REPO_DIR=$LAB_DIR/homelab/labs/$LAB_NAME

  mkdir $LAB_REPO_DIR/roles
  scp -r $LAB_DIR/config/roles/ovb-manage $LAB_REPO_DIR/roles

  ansible-playbook --inventory $LAB_REPO_DIR/inventory.yaml $LAB_REPO_DIR/create-ovb-stack.yaml -e lab_dir=$LAB_DIR


::

  ID_NUM=$(cat $LAB_DIR/ovb_working_dir/idnum)
  OVB_UNDERCLOUD=$(openstack stack output show baremetal_$ID_NUM undercloud_host_floating_ip -f value -c output_value)
  OVB_UNDERCLOUD_PUBLIC=10.0.0.254

  cat << EOF > inventory.ini
  [undercloud]
  $OVB_UNDERCLOUD ansible_user=centos ansible_ssh_extra_args='-o StrictHostKeyChecking=no' undercloud_public_ip=$OVB_UNDERCLOUD_PUBLIC idnum=$ID_NUM
  EOF

  ansible-playbook -i inventory.ini $LAB_DIR/homelab/labs/playbooks/ssh_hardening.yaml
  scp -o StrictHostKeyChecking=no $LAB_DIR/ovb_working_dir/instackenv.json centos@$OVB_UNDERCLOUD:
  ansible-playbook -i inventory.ini $LAB_REPO_DIR/deploy_undercloud.yaml


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
