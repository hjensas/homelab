ovb-podified lab
================

Set up OVB environment
----------------------

::

  export OS_CLOUD=homelab

  export LAB_NAME=ovb-podified
  export LAB_DIR=~/$LAB_NAME
  mkdir $LAB_DIR
  git clone https://github.com/hjensas/homelab.git $LAB_DIR/homelab
  export LAB_REPO_DIR=$LAB_DIR/homelab/labs/$LAB_NAME

  git clone https://review.rdoproject.org/r/config $LAB_DIR/config
  cd $LAB_DIR/config
  git fetch https://review.rdoproject.org/r/config refs/changes/79/46679/1 && git checkout FETCH_HEAD
  git switch -c port-security
  cd $LAB_DIR 

  mkdir $LAB_REPO_DIR/roles
  scp -r $LAB_DIR/config/roles/ovb-manage $LAB_REPO_DIR/roles

  ansible-playbook --inventory $LAB_REPO_DIR/inventory.yaml $LAB_REPO_DIR/create-ovb-stack.yaml -e lab_dir=$LAB_DIR

