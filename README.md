![Docker Build](https://github.com/slauger/hcloud-okd4/workflows/Docker%20Build/badge.svg) [![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=slauger/hcloud-okd4)](https://dependabot.com)


# hcloud-okd4

Deploy OKD4 (OpenShift) on Hetzner Cloud using Hashicorp Packer, Terraform and Ansible.

## Current status

The Hetzner Cloud does not fulfill the I/O performance/latency requirements for etcd - even when using local SSDs (instead of ceph storage). This could result in different problems during the cluster bootstrap. You could check the I/O performance via `etcdctl check perf`.

Because of that OpenShift on hcloud is only suitable for small test environments. Please do not use it for production clusters.

## Architecture

The deployment defaults to a 5 node cluster:

- 3x Master Nodes (CX41)
- 2x Worker Nodes (CX41)
- 1x Loadbalancer (LB11)
- 1x Bootstrap Node (CX41) - deleted after cluster bootstrap
- 1x Ignition Node (CX11) - deleted after cluster bootstrap

## Usage

### Set Version

Set a target version of use the targets `latest_version` and `latest_coreos_version` to fetch the latest available version.

```
export OPENSHIFT_RELEASE=$(make latest_version)
export COREOS_RELEASE=$(make latest_coreos_version)
```

### Build toolbox

To ensure that the we have a proper build environment, we create a toolbox container first.

```
make fetch
make build
```

### Run toolbox

Use the following command to start the container.

```
make run
```

All the following commands will be executed inside the container:

### Set Version

Set a target version of use the targets `latest_version` and `latest_coreos_version` to fetch the latest available version.

```
export OPENSHIFT_RELEASE=$(make latest_version)
export COREOS_RELEASE=$(make latest_coreos_version)
```

### Create your install-config.yaml

```
---
apiVersion: v1
baseDomain: example.com
metadata:
  name: okd4
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 0
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
networking:
  clusterNetworks:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
  none: {}
pullSecret: '{"auths":{"fake":{"auth":"aWQ6cGFzcwo="}}}'
sshKey: ssh-rsa AABBCC... Some_Service_User
```

### Create cluster manifests

```
make generate_manifests
```

### Create ignition config

```
make generate_ignition
```

### Set required environment variables

```
# terraform variables
export TF_VAR_dns_domain=okd4.example.com
export TF_VAR_dns_zone_id=14758f1afd44c09b7992073ccf00b43d

# credentials for hcloud
export HCLOUD_TOKEN=14758f1afd44c09b7992073ccf00b43d14758f1afd44c09b7992073ccf00b43d

# credentials for cloudflare
# https://dash.cloudflare.com/profile/api-tokens
# create token -> get started (create custom token) -> https://mktg-content-api-hashicorp.vercel.app/api/assets?product=tutorials&version=main&asset=public%2Fimg%2Fterraform%2Fuse-cases%2Fcloudflare-static-website%2Fcustom-api-token-settings.png
export CLOUDFLARE_EMAIL=user@example.com
export CLOUDFLARE_API_KEY=cloudflare_global_api_key
export CLOUDFLARE_API_TOKEN=cloudflare_api_token
```

### Create Fedora CoreOS image

Build a Fedora CoreOS hcloud image with Packer and embed the hcloud user data source (`http://169.254.169.254/hetzner/v1/userdata`).

```
make hcloud_image
```

### Build infrastructure with Terraform

```
make infrastructure BOOTSTRAP=true
```

### Wait for the bootstrap to complete

```
make wait_bootstrap
```

### Cleanup bootstrap and ignition node

```
make infrastructure
```

### Finish the installation process

```
make wait_completion
```

### Sign Worker CSRs

CSRs of the master nodes get signed by the bootstrap node automaticaly during the cluster bootstrap. CSRs from worker nodes must be signed manually.

```
make sign_csr
sleep 60
make sign_csr
```

This step is not necessary if you set `replicas_worker` to zero.

## Hetzner CSI

To install the CSI driver create a secret with your hcloud token first.

```
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: hcloud-csi
  namespace: kube-system
stringData:
  token: ${HCLOUD_TOKEN}
EOF
```

After that just apply the the following manifest.

```
oc apply -f https://raw.githubusercontent.com/slauger/csi-driver/openshift/deploy/kubernetes/hcloud-csi-openshift.yml
```

## Deployment of OCP

It's also possible OCP (with RedHat CoreOS) instead of OKD. Just export `DEPLOYMENT_TYPE=ocp`. For example:

```
export DEPLOYMENT_TYPE=ocp
export OPENSHIFT_RELEASE=4.6.35
export COREOS_RELEASE=4.6.8
make fetch build run
```

Besides that a RedHat OpenShift pull secret is necessary, which could be obtained from [cloud.redhat.com](https://cloud.redhat.com/).

## Enforce Firewall rules

As the Terraform module from Hetzer is currently unable to produce applied rules that contain hosts you deploy at the same time, you have to deploy them afterwards.

In order to do that, you should visit your Hetzner Web Console and apply the `okd-master` firewall rule to all hosts with the label `okd.io/master: true`, the `okd-base` to the label `okd.io/node: true` and `okd-ingress` to all nodes with the `okd.io/ingress: true` label. Since terraform will ignore firewall changes, this should not interfere with your existing state.

Note: This will keep hosts pingable, but isolate them complete from the internet, making the cluster only reachable through the load balancer. If you require direct SSH access, you can add another rule, that you apply nodes that allows access to port 22.

## Cloudflare API Token

Checkout [this issue](https://github.com/slauger/hcloud-okd4/issues/176) to get details about how to obtain an API token for the Cloudflare API.

## Multi-tenancy networking with OVN-Kubernetes
See [Configuring multitenant isolation with network policy](https://docs.openshift.com/container-platform/4.10/networking/network_policy/multitenant-network-policy.html).

## Original author

- [slauger](https://github.com/slauger)
