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

- **zones** are AWS zones
- **channel** Source Channel, if it is stable or edge
- **cloud** is the cloud provider
- **cloud-labels** are labels to tag instances with
- **dns** defines if dns routing is public or private
- **dns-zone** is mapped route-53 domain
- **master-count** is number of master nodes
- **master-size** is instance type of master nodes
- **networking** is networking type. Other options are `flannel`, `weave`. Refer [kubernetes/networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/) for more details
- **node-count** is count of nodes
- **node-size** is instance types of nodes
- **node-volume-size** is size of disk attached to node
- **image** is the image (in case of AWS - AMI) used to create the instances
- **name** is the name of the cluster
- **state** is s3 bucket in which kops puts its cluster state

> **Note**, use `kops create cluster --help` to view other options

This command creates a Kubernetes cluster with 1 master node of type c5d.large & 3 nodes of type c5d.xlarge on AWS.

#### Creating Cluster Using YAML

To create Kubernetes cluster, use the Kops as YAML command to create cluster.

**Create Cluster**

`kops create -f ./kops/ack-calico-c5d.yaml --name ack.unbxd.io --state s3://ack-kops-state`

**Create Secret**

`kops create secret --name ack.unbxd.io sshpublickey admin -i ./kops/key/kops.key.pub --state s3://ack-kops-state`

> **Note:** kops.key.pub is part of a keypair, where public key is kops.key.pub & private being kops.key

**Update Cluster**

`kops update cluster ack.unbxd.io --yes --state s3://ack-kops-state`

**Validate Cluster**

`kops validate cluster --state s3://ack-kops-state --name ack.unbxd.io` 

There are multiple YAML files in [kops](kops) directory, to support different networking & instance types. 

> **Quirks:**
> Some Instance types are not supported by Kops. Images built using Debian Jessie do not have NVME drivers.
> Workarounds to get the setup working
>
> - Use Images from CoreOS. Pass `--image {image_name}` in Kops command. To get the image fire use this script
>     `curl -s https://coreos.com/dist/aws/aws-stable.json | jq -r '."us-west-2".hvm'`
> - Use Debian Stretch image
> 
> RBAC roles are turned off for the test cluster, to support RBAC ClusterRole needs to be defined

## Preparing Kubernetes Cluster

Following steps are not necessary to run Zookeeper or Solr, however these helps us measure & debug any issues in network. For this demo the we have two YAMLs for both Solr & Zookeeper, one with prepared dependencies and one without.

If you plan to skip this step, use the YAML [kubectl/apps/zk/zk.yaml](kubectl/apps/zk/zk.yaml) for Zookeeper & [kubectl/apps/solr/solr.yaml](kubectl/apps/solr/solr.yaml) for Solr.

### Setting Up Istio

[Istio](https://istio.io) Istio is a service mesh that lets us connect, secure, control and observe serices in our Kubernets network.

#### Create Cluster Using YAML

**Create Crds** 

Istio Creates CustomResourceDefinitions for the cluster. The YAML present at [kubectl/base/istio/crds.yaml](kubectl/base/istio/crds.yaml) can be applied directly to the cluster using 

`kubectl apply -f kubectl/base/istio/crds.yaml`

**Install Istio Base System**
Istio installs a ton of things along with the base service mesh. These are primarily to visualize and debug any issues present. 


