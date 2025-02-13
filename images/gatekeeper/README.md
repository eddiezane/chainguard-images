<!--monopod:start-->
# gatekeeper
| | |
| - | - |
| **Status** | stable |
| **OCI Reference** | `cgr.dev/chainguard/gatekeeper` |
| **Variants/Tags** | ![](https://storage.googleapis.com/chainguard-images-build-outputs/summary/gatekeeper.svg) |

*[Contact Chainguard](https://www.chainguard.dev/chainguard-images) for enterprise support, SLAs, and access to older tags.*

---
<!--monopod:end-->

Minimalist Wolfi-based Gatekeeper which is a policy controller for Kubernetes

## Get It!

The image is available on `cgr.dev`:

```
docker pull cgr.dev/chainguard/gatekeeper:latest
```

## Usage

This image should be a drop-in replacement for the upstream `opa/gatekeeper` image.
See the [full documentation](https://open-policy-agent.github.io/gatekeeper/website/) for installation and usage.

See for the [examples](https://open-policy-agent.github.io/gatekeeper/website/docs/examples).

We can use the Chainguard image that we've built for Gatekeeper with the Helm chart of the project using the following commands.

First, you need to install the Helm repository:

```shell
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
```

Once you did this, you can install Gatekeeper to the target cluster:

```shell
   helm install --name-template=gatekeeper \
		--namespace gatekeeper-system \
		--create-namespace \
	    --set image.repository="cgr.dev/chainguard/gatekeeper" \
	    --set image.release="latest" \
        gatekeeper/gatekeeper
```
