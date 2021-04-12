ovb-ipv4-routed lab
===================

Set up OVB environment
----------------------

::

  export OS_CLOUD=homelab

  export LAB_NAME=ovb-ipv4-tls-e-routed
  export LAB_DIR=~/$LAB_NAME
  mkdir $LAB_DIR
  git clone https://github.com/hjensas/homelab.git $LAB_DIR/homelab
  export LAB_REPO_DIR=$LAB_DIR/homelab/labs/$LAB_NAME

  git clone https://review.rdoproject.org/r/config $LAB_DIR/config
  cd $LAB_DIR/config
  git fetch https://review.rdoproject.org/r/config refs/changes/00/30500/6 && git checkout FETCH_HEAD
  git switch -c routed-networks-support
  cd $LAB_DIR 

  mkdir $LAB_REPO_DIR/roles
  scp -r $LAB_DIR/config/roles/ovb-manage $LAB_REPO_DIR/roles

  ansible-playbook --inventory $LAB_REPO_DIR/inventory.yaml $LAB_REPO_DIR/create-ovb-stack.yaml -e lab_dir=$LAB_DIR


::

  ID_NUM=$(cat $LAB_DIR/ovb_working_dir/idnum)
  OVB_UNDERCLOUD=$(openstack stack output show baremetal_$ID_NUM undercloud_host_floating_ip -f value -c output_value)
  OVB_UNDERCLOUD_PUBLIC=10.0.0.1

  FREEIPA=$(openstack port list --server baremetal-$ID_NUM-extra_0 --network private -f json -c "Fixed IP Addresses" | jq '.[0]."Fixed IP Addresses"[0]."ip_address"' --raw-output)
  FREEIPA_CTLPLANE=$(openstack port list --server baremetal-$ID_NUM-extra_0 --network ctlplane-$ID_NUM -f json -c "Fixed IP Addresses" | jq '.[0]."Fixed IP Addresses"[0]."ip_address"' --raw-output)
  IPA_PASSWORD=$(uuidgen)

  cat << EOF > inventory.ini
  [all:children]
  undercloud
  freeipa

  [undercloud]
  $OVB_UNDERCLOUD ansible_user=cloud-user ansible_ssh_extra_args='-o StrictHostKeyChecking=no' undercloud_public_ip=$OVB_UNDERCLOUD_PUBLIC idnum=$ID_NUM
  
  [freeipa]
  $FREEIPA ansible_user=cloud-user ansible_ssh_extra_args='-o StrictHostKeyChecking=no -J cloud-user@$OVB_UNDERCLOUD' ctlplane_ip=$FREEIPA_CTLPLANE
  
  [all:vars]
  freeipa_ip=$FREEIPA_CTLPLANE
  ipa_password=$IPA_PASSWORD
  EOF


  ansible-playbook -i inventory.ini $LAB_DIR/homelab/labs/playbooks/ssh_hardening.yaml
  scp -o StrictHostKeyChecking=no $LAB_DIR/ovb_working_dir/instackenv.json cloud-user@$OVB_UNDERCLOUD:

  ansible-playbook -i inventory.ini $LAB_REPO_DIR/deploy_freeipa.yaml

  ansible-playbook -i inventory.ini $LAB_REPO_DIR/deploy_undercloud.yaml


Deploy the overcloud
--------------------

Log into the ovb undercloud node, user: cloud-user.

Deploy with routed networks::

  bash ~/overcloud/deploy_overcloud.sh
