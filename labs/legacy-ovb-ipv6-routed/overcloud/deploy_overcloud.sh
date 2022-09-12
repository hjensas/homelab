#!/bin/bash

source /home/centos/stackrc
cd /home/centos

openstack overcloud deploy 
  --templates /home/centos/tripleo-heat-templates \
  -n /home/centos/overcloud/network_data.yaml \
  -r /home/centos/overcloud/roles_data.yaml \
  --deployed-server \
  --disable-validations \
  -e /home/centos/tripleo-heat-templates/environments/deployed-server-environment.yaml \
  -e /home/centos/overcloud-baremetal-deployed.yaml \
  -e /home/centos/tripleo-heat-templates/environments/enable-swap.yaml \
  -e /home/centos/tripleo-heat-templates/environments/network-isolation.yaml \
  -e /home/centos/tripleo-heat-templates/environments/network-environment.yaml \
  -e /home/centos/overcloud/nic-configs/net-multiple-nics.yaml \
  -e /home/centos/overcloud/environments/node_data.yaml
