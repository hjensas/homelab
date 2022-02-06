#!/bin/bash

source /home/centos/stackrc
cd /home/centos


openstack overcloud network provision \
  --output /home/centos/overcloud-networks-deployed.yaml \
  --templates /home/centos/tripleo-heat-templates \
  --stack overcloud \
  /home/centos/overcloud/network_data_v2.yaml 


