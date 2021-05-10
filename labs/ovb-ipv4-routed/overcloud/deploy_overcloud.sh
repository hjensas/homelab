#!/bin/bash

source /home/centos/stackrc
cd /home/centos

openstack overcloud deploy --templates /home/centos/tripleo-heat-templates \
  --deployed-server \
  --disable-validations \
  -n /home/centos/overcloud/network_data_v2.yaml \
  -r /home/centos/overcloud/my_roles_data.yaml \
  -e /home/centos/tripleo-heat-templates/environments/deployed-server-environment.yaml \
  -e /home/centos/overcloud-baremetal-deployed.yaml \
  -e /home/centos/overcloud-networks-deployed.yaml \
  -e /home/centos/overcloud-vips-deployed.yaml \
  -e /home/centos/tripleo-heat-templates/environments/enable-swap.yaml \
  -e /home/centos/tripleo-heat-templates/environments/network-isolation.yaml \
  -e /home/centos/tripleo-heat-templates/environments/net-multiple-nics.yaml \
  -e /home/centos/overcloud/node_data.yaml

