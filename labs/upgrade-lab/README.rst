upgrade-lab
===========

Set up OVB environment
----------------------

::

  export OS_CLOUD=homelab

  export LAB_NAME=upgrade-lab
  export LAB_DIR=~/$LAB_NAME
  mkdir $LAB_DIR
  git clone https://github.com/hjensas/homelab.git $LAB_DIR/homelab
  export LAB_REPO_DIR=$LAB_DIR/homelab/labs/$LAB_NAME

  git clone https://review.rdoproject.org/r/config $LAB_DIR/config
  cd $LAB_DIR/config
  git fetch https://review.rdoproject.org/r/config refs/changes/36/33636/1 && git checkout FETCH_HEAD
  git switch -c routed-networks-support
  cd $LAB_DIR

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
  ansible-playbook -i inventory.ini $LAB_REPO_DIR/deploy.yaml

