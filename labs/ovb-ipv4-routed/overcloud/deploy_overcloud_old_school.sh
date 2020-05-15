#!/bin/bash

source /home/centos/stackrc
cd /home/centos

openstack overcloud deploy --templates /home/centos/tripleo-heat-templates \
  -n /home/centos/overcloud/templates/old_school_network_data.yaml \
  -r /home/centos/overcloud/templates/old_school_roles_data.yaml \
  -e /home/centos/tripleo-heat-templates/environments/enable-swap.yaml \
  -e /home/centos/overcloud/environments/old_school_node_data.yaml \
  -e /home/centos/tripleo-heat-templates/environments/network-isolation.yaml \
  -e /home/centos/tripleo-heat-templates/environments/network-environment.yaml \
  -e /home/centos/overcloud/nic-configs/net-multiple-nics.yaml \
  -e /home/centos/tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \
  -e /home/centos/overcloud/environments/network-environment-overrides.yaml


