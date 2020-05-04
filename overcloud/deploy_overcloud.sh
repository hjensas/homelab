#!/bin/bash

source /home/stack/stackrc
cd /home/stack

openstack overcloud deploy \
  --templates \
  -r /home/stack/overcloud/aio_roles_data.yaml \
  -n /home/stack/overcloud/network_data_empty.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/enable-swap.yaml \
  -e /home/stack/overcloud/nodes.yaml
  
