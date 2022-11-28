#. RH Hybrid Cloud Console - Red Hat OpenStack Platform
   Installer-provisioned infrastructure - https://console.redhat.com/openshift/install/openstack/installer-provisioned
   ::
     cp ./install-config.yaml ./install_dir/
   Edit ``./install_dir/install-config.yaml``, add the pull secret.
   ::
     ./openshift-install create cluster --dir install_dir/

#. Export oauth config
   ::
     oc get oauth cluster -o yaml > oauth.yaml

#. Create httpasswd file
   ::
     htpasswd -c -B -b htpasswd admin admin
     htpasswd -c -B -b htpasswd openstack openstack

#. Edit then replace config
   ::
     oc replace -f oauth.yaml

#. Create HTPasswd secret
   ::
     oc create secret generic htpasswd-secret --from-file htpasswd=./htpasswd -n openshift-config
     
#. Add Admin privilegies to admin user
   ::
     oc adm policy add-cluster-role-to-user cluster-admin admin

#. Checkout install_yamls and install operators
   ::
     git clone https://github.com/openstack-k8s-operators/install_yamls.git
     make mariadb MARIADB_IMG=quay.io/openstack-k8s-operators/mariadb-operator-index:latest
     make keystone KEYSTONE_IMG=quay.io/openstack-k8s-operators/keystone-operator-index:latest

#. Deploy MariaDB and Keystone
   ::
     make mariadb_deploy STORAGE_CLASS=standard-csi
     make keystone_deploy

#. Deploy Ironic
   ::
     make ironic                                     # Deploy the operator
     make ironic_deploy STORAGE_CLASS=standard-csi   # Deploy ironic


