#!/bin/bash

source /home/centos/stackrc
cd /home/centos

openstack overcloud deploy --stack overcloud \
  --templates \
  -n /home/centos/overcloud/network_data.yaml \
  -r /home/centos/overcloud/my_roles_data.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/enable-swap.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/net-multiple-nics.yaml \
  -e /home/centos/overcloud/node_data.yaml

