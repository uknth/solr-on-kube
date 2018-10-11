# Solr On Kubernetes

## Creating Kubernetes Cluster

To create `Kubernetes` cluster we use will be using [kops](https://github.com/kubernetes/kops) on AWS. 

### Command

```
kops create cluster                                                         \
    --zones us-east-2a,us-east-2b,us-east-2c                                \
    --authorization AlwaysAllow                                             \
    --channel stable                                                        \
    --cloud aws                                                             \
    --cloud-labels "Owner=Ujjwal Kanth,Team=Activate-Conf,Source=Activate"  \
    --dns public                                                            \
    --dns-zone ack.unbxd.io                                                 \
    --master-count 1                                                        \
    --master-size c5d.large                                                 \
    --networking calico                                                     \
    --node-count 3                                                          \
    --node-size c5d.xlarge                                                  \
    --node-volume-size 100                                                  \
    --image ami-093e794c03f1534e4                                           \
    --name ack.unbxd.io                                                     \
    --state s3://ack-kops-state                                             \
    --dry-run                                                               \
    -o yaml
```

Explanation

- zones: AWS zones
- channel: Source Channel, if it is stable or edge
- cloud: cloud provider
- cloud-labels: Labels to tag instances with
- dns: public or private dns routing
- dns-zone: mapped route-53 domain
- master-count: count of master
- master-size: instance type of master nodes
- networking: networking type
- node-count: count of nodes
- node-size: size of node
- node-volume-size: size of disk attached to node
- image: image(AMI) to use to create master/nodes
- name: name of the cluster
- state: s3 bucket in which kops puts its cluster state

This command creates a Kubernetes cluster with 1 master node of type c5d.large & 3 nodes of type c5d.xlarge on AWS.

#### Creating Cluster Using YAML

To create Kubernetes cluster, use the Kops as YAML command to create cluster.

Create Cluster:

- `kops create -f ./ref/kops/ack-calico-c5d.yaml --name ack.unbxd.io --state s3://ack-kops-state`

Create Secret:

- `kops create secret --name ack.unbxd.io sshpublickey admin -i ./ref/kops/key/kops.key.pub --state s3://ack-kops-state`

> Note: kops.key.pub is part of a keypair, where public key is kops.key.pub & private being kops.key

Update Cluster:

- `kops update cluster ack.unbxd.io --yes --state s3://ack-kops-state`


This creates the cluster. To validate if the cluster is working, use command:

- `kops validate cluster --state s3://ack-kops-state --name ack.unbxd.io` 

There are multiple YAML files in [kops](ref/kops) directory, to support different networking & instance types. 

> Quirks:
>
> - Some Instance types are not supported by Kops. Images built using Debian Jessie do not have NVME drivers.
>   Workarounds:
>  	- Use Images from CoreOS
>  		- Pass `--image {image_name}` in command
>  		- To get the image fire use this script
>  		  `curl -s https://coreos.com/dist/aws/aws-stable.json | jq -r '."us-west-2".hvm'`
>
>  	- Use Debian Stretch image
> 
> - RBAC roles are turned off for the test cluster, to support RBAC ClusterRole needs to be defined

## Preparing Kubernetes Cluster

