# Cloud images

Makefile to download and customize cloud images by installing additional packages.

## Download and customize image

```
make all
```

## Cleanup

```
make clean
```


## Upload controller image to glance

```
openstack image create --disk-format qcow2 --file controller.qcow2 dffw-controller
```
