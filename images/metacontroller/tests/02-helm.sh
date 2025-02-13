#!/usr/bin/env bash

# monopod:tag:k8s

set -o errexit -o nounset -o errtrace -o pipefail -x

function preflight() {
  if [[ "${IMAGE_REGISTRY}" == "" ]]; then
    echo "Must set IMAGE_REGISTRY environment variable. Exiting."
    exit 1
  fi

  if [[ "${IMAGE_REPOSITORY}" == "" ]]; then
    echo "Must set IMAGE_REPOSITORY environment variable. Exiting."
    exit 1
  fi

  if [[ "${IMAGE_TAG}" == "" ]]; then
    echo "Must set IMAGE_TAG environment variable. Exiting."
    exit 1
  fi
}

preflight

function cleanup() {
    # Get the logs from metacontroller before exiting
    kubectl describe pod --selector  app.kubernetes.io/instance=my-metacontroller-helm
    kubectl logs --selector  app.kubernetes.io/instance=my-metacontroller-helm
}

trap cleanup EXIT

export HELM_EXPERIMENTAL_OCI=1
helm install my-metacontroller-helm oci://ghcr.io/metacontroller/metacontroller-helm --version v4.10.3  \
    --set image.repository="${IMAGE_REGISTRY}/${IMAGE_REPOSITORY}" \
    --set image.tag="${IMAGE_TAG}" \
    --set image.pullPolicy=IfNotPresent


kubectl create namespace hello

cat <<EOF > crd.yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: helloworlds.example.com
spec:
  group: example.com
  names:
    kind: HelloWorld
    plural: helloworlds
    singular: helloworld
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              who:
                type: string
    subresources:
     status: {}
EOF

kubectl apply -f crd.yaml

cat <<EOF > hello.yaml
apiVersion: metacontroller.k8s.io/v1alpha1
kind: CompositeController
metadata:
  name: hello-controller
spec:
  generateSelector: true
  parentResource:
    apiVersion: example.com/v1
    resource: helloworlds
  childResources:
  - apiVersion: v1
    resource: pods
    updateStrategy:
      method: Recreate
  hooks:
    sync:
      webhook:
        url: http://hello-controller.hello/sync
EOF

kubectl apply -f hello.yaml

cat <<EOF > sync.py
from http.server import BaseHTTPRequestHandler, HTTPServer
import json

class Controller(BaseHTTPRequestHandler):
  def sync(self, parent, children):
    # Compute status based on observed state.
    desired_status = {
      "pods": len(children["Pod.v1"])
    }

    # Generate the desired child object(s).
    who = parent.get("spec", {}).get("who", "World")
    desired_pods = [
      {
        "apiVersion": "v1",
        "kind": "Pod",
        "metadata": {
          "name": parent["metadata"]["name"]
        },
        "spec": {
          "restartPolicy": "OnFailure",
          "containers": [
            {
              "name": "hello",
              "image": "busybox",
              "command": ["echo", "Hello, %s!" % who]
            }
          ]
        }
      }
    ]

    return {"status": desired_status, "children": desired_pods}

  def do_POST(self):
    # Serve the sync() function as a JSON webhook.
    observed = json.loads(self.rfile.read(int(self.headers.get("content-length"))))
    desired = self.sync(observed["parent"], observed["children"])

    self.send_response(200)
    self.send_header("Content-type", "application/json")
    self.end_headers()
    self.wfile.write(json.dumps(desired).encode())

HTTPServer(("", 80), Controller).serve_forever()
EOF

kubectl -n hello create configmap hello-controller --from-file=sync.py



cat <<EOF > webhook.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-controller
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-controller
  template:
    metadata:
      labels:
        app: hello-controller
    spec:
      containers:
      - name: controller
        image: python:3
        command: ["python3", "/hooks/sync.py"]
        volumeMounts:
        - name: hooks
          mountPath: /hooks
      volumes:
      - name: hooks
        configMap:
          name: hello-controller
---
apiVersion: v1
kind: Service
metadata:
  name: hello-controller
spec:
  selector:
    app: hello-controller
  ports:
  - port: 80
EOF


kubectl -n hello apply -f webhook.yaml

cat <<EOF > hello.yaml
apiVersion: example.com/v1
kind: HelloWorld
metadata:
  name: chainguard
spec:
  who: chainguard
EOF

kubectl -n hello apply -f hello.yaml

# Sleep  theh ello controller kicks in 
sleep 30

kubectl get pods chainguard --output=jsonpath='{.status.phase}' -n hello | grep "Succeeded"

sleep 5

kubectl logs pod/chainguard -n hello |  grep "chainguard"

