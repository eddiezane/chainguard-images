<!--monopod:start-->
# memcached-exporter
| | |
| - | - |
| **Status** | experimental |
| **OCI Reference** | `cgr.dev/chainguard/memcached-exporter` |
| **Variants/Tags** | ![](https://storage.googleapis.com/chainguard-images-build-outputs/summary/memcached-exporter.svg) |

*[Contact Chainguard](https://www.chainguard.dev/chainguard-images) for enterprise support, SLAs, and access to older tags.*

---
<!--monopod:end-->

A memcached exporter for Prometheus.

## Get It!

The image is available on `cgr.dev`:

```
docker pull cgr.dev/chainguard/memcached-exporter
```

## Using Memcached

By default the memcached-exporter serves on port 0.0.0.0:9150 at /metrics:

```sh
docker run -p 9150:9150 cgr.dev/chainguard/memcached-exporter:latest
```

```sh
$ docker run -p 9150:9150 ghcr.io/tuananh/memcached-exporter:latest
ts=2023-04-26T17:47:53.477Z caller=main.go:58 level=info msg="Starting memcached_exporter" version="(version=0.11.2, branch=HEAD, revision=48795923bbe6c23eb044c522283e0d865bffbc77)"
ts=2023-04-26T17:47:53.478Z caller=main.go:59 level=info msg="Build context" context="(go=go1.20.3, platform=linux/amd64, user=@fv-az251-622, date=19700101-00:00:00, tags=netgo)"
ts=2023-04-26T17:47:53.478Z caller=tls_config.go:232 level=info msg="Listening on" address=[::]:9150
ts=2023-04-26T17:47:53.478Z caller=tls_config.go:235 level=info msg="TLS is disabled." http2=false address=[::]:9150
```

## Users and Directories

By default this image runs as a non-root user named `nonroot` with a uid of 65532.
