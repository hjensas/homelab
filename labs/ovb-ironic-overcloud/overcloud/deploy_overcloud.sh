#!/bin/bash

source /home/centos/stackrc
cd /home/centos

openstack overcloud deploy --templates /home/centos/tripleo-heat-templates \
  -n /home/centos/overcloud/templates/network_data_subnets_routed.yaml \
  -r /home/centos/overcloud/templates/my_roles_data.yaml \
  --deployed-server \
  --disable-validations \
  -e /usr/share/openstack-tripleo-heat-templates/environments/deployed-server-environment.yaml \
  -e /home/centos/overcloud-baremetal-deployed.yaml \
  -e /home/centos/tripleo-heat-templates/environments/enable-swap.yaml \
  -e /home/centos/tripleo-heat-templates/environments/services/neutron-ovs.yaml \
  -e /home/centos/tripleo-heat-templates/environments/services/ironic-overcloud.yaml \
  -e /home/centos/tripleo-heat-templates/environments/network-isolation.yaml \
  -e /home/centos/tripleo-heat-templates/environments/network-environment.yaml \
  -e /home/centos/overcloud/nic-configs/net-multiple-nics.yaml \
  -e /home/centos/overcloud/environments/node_data.yaml

