pre-deployed-nodes lab
======================

Set up OVB environment
----------------------

::

  export OS_CLOUD=homelab

  export LAB_NAME=pre-deployed-nodes
  export LAB_DIR=~/$LAB_NAME
  mkdir $LAB_DIR
  git clone https://github.com/hjensas/homelab.git $LAB_DIR/homelab
  export LAB_REPO_DIR=$LAB_DIR/homelab/labs/$LAB_NAME

  git clone https://review.rdoproject.org/r/config $LAB_DIR/config
  cd $LAB_DIR/config
  git fetch "https://review.rdoproject.org/r/config" refs/changes/34/34034/4 && git checkout FETCH_HEAD
  git switch -c virtualenv-python
  git rebase master
  cd $LAB_DIR

  mkdir $LAB_REPO_DIR/roles
  scp -r $LAB_DIR/config/roles/ovb-manage $LAB_REPO_DIR/roles

  ansible-playbook --inventory $LAB_REPO_DIR/inventory.yaml $LAB_REPO_DIR/create-ovb-stack.yaml -e lab_dir=$LAB_DIR

::

  ID_NUM=$(cat $LAB_DIR/ovb_working_dir/idnum)
  OVB_UNDERCLOUD=$(openstack stack output show baremetal_$ID_NUM undercloud_host_floating_ip -f value -c output_value)
  OVB_UNDERCLOUD_PUBLIC=10.0.0.254
  OVB_BAREMETAL_LEAF1_0=$(jq --raw-output ".network_details.\"baremetal-$ID_NUM-leaf1_0\".ips.\"ctlplane-leaf1-$ID_NUM\"[0].addr" $LAB_DIR/ovb_working_dir/instackenv.json)
  OVB_BAREMETAL_LEAF2_0=$(jq --raw-output ".network_details.\"baremetal-$ID_NUM-leaf2_0\".ips.\"ctlplane-leaf2-$ID_NUM\"[0].addr" $LAB_DIR/ovb_working_dir/instackenv.json)
  cat << EOF > inventory.ini
  [undercloud]
  undercloud-host ansible_host=$OVB_UNDERCLOUD ansible_user=centos ansible_ssh_extra_args='-o StrictHostKeyChecking=no' undercloud_public_ip=$OVB_UNDERCLOUD_PUBLIC idnum=$ID_NUM

  [overcloud]
  baremetal-leaf1-0 ansible_host=$OVB_BAREMETAL_LEAF1_0 ansible_user=centos ansible_ssh_extra_args='-o StrictHostKeyChecking=no -J centos@$OVB_UNDERCLOUD,centos@192.168.24.253' gateway=192.168.25.254
  baremetal-leaf2-0 ansible_host=$OVB_BAREMETAL_LEAF2_0 ansible_user=centos ansible_ssh_extra_args='-o StrictHostKeyChecking=no -J centos@$OVB_UNDERCLOUD,centos@192.168.24.253' gateway=192.168.26.254
  EOF

  ansible -i inventory.ini baremetal-leaf1-0 -a "ip route add default via 192.168.25.254" --become
  ansible -i inventory.ini baremetal-leaf2-0 -a "ip route add default via 192.168.26.254" --become

  ansible-playbook -i inventory.ini $LAB_DIR/homelab/labs/playbooks/ssh_hardening.yaml
  scp -o StrictHostKeyChecking=no $LAB_DIR/ovb_working_dir/instackenv.json centos@$OVB_UNDERCLOUD:
  ansible-playbook -i inventory.ini $LAB_REPO_DIR/deploy_undercloud.yaml
  ansible-playbook -i inventory.ini $LAB_REPO_DIR/prep-pre-deployed-nodes.yaml


