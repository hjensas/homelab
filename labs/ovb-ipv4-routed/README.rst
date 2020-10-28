ovb-ipv4-routed lab
===================

Set up OVB environment
----------------------

::

  export LAB_DIR=~/ovb-ipv4-routed
  mkdir $LAB_DIR
  virtualenv --system-site-packages $LAB_DIR/venv
  source $LAB_DIR/venv/bin/activate
  pip install ansible
  mkdir $LAB_DIR/roles
  git clone https://review.rdoproject.org/r/config $LAB_DIR/config
  cd $LAB_DIR/config
  git fetch https://review.rdoproject.org/r/config refs/changes/25/30625/1 && git checkout FETCH_HEAD
  git switch -c optional-create-clouds-yaml
  git fetch https://review.rdoproject.org/r/config refs/changes/90/30490/2 && git checkout FETCH_HEAD
  git switch -c routed-networks-support
  git rebase optional-create-clouds-yaml
  cd $LAB_DIR 

  scp -r $LAB_DIR/config/roles/ovb-manage $LAB_DIR/roles/
  cat << EOF > $LAB_DIR/inventory.yaml
  all:
    hosts:
      localhost:
        ovb_working_dir: $LAB_DIR/ovb_working_dir
        ovb_clone: true
        ovb_repo_version: master
        ovb_repo_directory: $LAB_DIR/openstack-virtual-baremetal
        create_undercloud: true
        attach_to_ovb_networks: false
        routed_networks: true
        nodes: zero_nodes
        leaf1_nodes: 1
        leaf2_nodes: 1
        net_iso: multi-nic
        key_name: default
        create_clouds_yaml: false
        cloud_name: homelab
        baremetal_image_name: ipxe-boot
        bmc_template_name: CentOS-7-x86_64-GenericCloud
        env_args: >-
         -e {{ ovb_working_dir }}/env-{{ idnum }}-base.yaml
         -e {{ ovb_repo_directory }}/environments/bmc-use-cache.yaml
        cloud_settings:
          homelab:
            public_ip_net: public
            undercloud_flavor: m1.large # not used
            baremetal_flavor: m1.large
            bmc_flavor: m1.small
            extra_node_flavor: m1.small
            baremetal_image: CentOS-8-GenericCloud
            radvd_flavor: m1.small
            radvd_image: CentOS-7-x86_64-GenericCloud
            dhcp_relay_image: CentOS-7-x86_64-GenericCloud
            dhcp_relay_flavor: m1.small
            external_net: provider
  EOF
  cat << EOF > $LAB_DIR/create-ovb-stack.yaml
  - name: Create the OVB stack
    hosts: localhost
    roles:
      - { role: ovb-manage, ovb_manage_stack_mode: 'create' }
  EOF
  ansible-playbook --inventory $LAB_DIR/inventory.yaml $LAB_DIR/create-ovb-stack.yaml

  export OS_CLOUD=homelab
  git clone https://github.com/hjensas/homelab.git /homelab
  ID_NUM=$(cat $LAB_DIR/ovb_working_dir/idnum)
  OVB_UNDERCLOUD=$(openstack stack output show baremetal_$ID_NUM undercloud_host_floating_ip -f value -c output_value)
  OVB_UNDERCLOUD_PUBLIC=10.0.0.254

  cat << EOF > inventory.ini
  [undercloud]
  $OVB_UNDERCLOUD ansible_user=centos ansible_ssh_extra_args='-o StrictHostKeyChecking=no' undercloud_public_ip=$OVB_UNDERCLOUD_PUBLIC idnum=$ID_NUM
  EOF

  ansible-playbook -i ovb-inventory.ini $LAB_DIR/homelab/labs/playbooks/ssh_hardening.yaml

  scp $LAB_DIR/ovb_working_dir/instackenv.json centos@$OVB_UNDERCLOUD:
  DEPLOY_UNDERCLOUD="ansible-playbook -i inventory.ini $LAB_DIR/homelab/labs/ovb-ipv4-routed/playbooks//deploy_undercloud.yaml"
  DEPLOY_OVERCLOUD="Log into undercloud ($OVB_UNDERCLOUD) and run command: bash ~/overcloud/deploy_overcloud.sh"
  echo "###############################################"
  echo -e "Undercloud floating IP:\n\t$OVB_UNDERCLOUD"
  echo -e "Deploy undercloud:\n\t$DEPLOY_UNDERCLOUD"
  echo -e "Deploy overcloud:\n\t$DEPLOY_OVERCLOUD"
  echo "###############################################"


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
