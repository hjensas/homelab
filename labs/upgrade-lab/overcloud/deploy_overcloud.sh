#!/bin/bash

source /home/centos/stackrc
cd /home/centos

openstack overcloud deploy --templates \
  -n /home/centos/overcloud/network_data_v1.yaml \
  -r /home/centos/overcloud/my_roles_data.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/enable-swap.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/net-multiple-nics.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/services/zaqar.yaml
  -e /home/centos/overcloud/node_data.yaml

