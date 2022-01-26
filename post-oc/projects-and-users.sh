#!/bin/bash

source /home/stack/overcloudrc

openstack project create --description "Haralds Project" hjensas --domain default
openstack user create --project hjensas --password $1 hjensas
openstack role add --user hjensas --project hjensas member

