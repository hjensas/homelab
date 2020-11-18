#!/bin/bash

source /home/centos/stackrc
cd /home/centos


openstack overcloud network provision \
  --networks-file /home/centos/overcloud/network_data_v2.yaml \
  --output /home/centos/overcloud-networks-deployed.yaml

sed -i 's|/usr/share/openstack-tripleo-heat-templates|/home/centos/tripleo-heat-templates|g' /home/centos/overcloud-networks-deployed.yaml

