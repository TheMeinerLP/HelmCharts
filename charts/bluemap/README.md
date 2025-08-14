# BlueMap Helm Chart

This Helm chart deploys [BlueMap](https://github.com/BlueMap-Minecraft/BlueMap), a Minecraft map renderer and web viewer, on a Kubernetes cluster.

## Introduction

BlueMap is an open-source Minecraft mapping tool that creates 3D models of your Minecraft worlds and displays them in a web viewer. This Helm chart makes it easy to deploy BlueMap in a Kubernetes environment.

## Prerequisites

- Kubernetes 1.14+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (if persistence is needed)

## Installing the Chart

To install the chart with the release name `my-bluemap`:

```bash
helm install my-bluemap ./charts/bluemap
```

The command deploys BlueMap on the Kubernetes cluster with default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-bluemap` deployment:

```bash
helm delete my-bluemap
```

## Parameters

### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `replicaCount`            | Number of BlueMap replicas to deploy            | `1`   |
| `nameOverride`            | String to partially override bluemap.fullname   | `""`  |
| `fullnameOverride`        | String to fully override bluemap.fullname       | `""`  |

### BlueMap Image parameters

| Name                | Description                                          | Value                           |
| ------------------- | ---------------------------------------------------- | ------------------------------- |
| `image.repository`  | BlueMap image repository                             | `ghcr.io/bluemap-minecraft/bluemap` |
| `image.tag`         | BlueMap image tag (immutable tags are recommended)   | `v5.11`                         |
| `image.pullPolicy`  | BlueMap image pull policy                            | `IfNotPresent`                  |
| `imagePullSecrets`  | Specify docker-registry secret names                 | `[]`                           |

### BlueMap Configuration parameters

| Name                       | Description                                                | Value                           |
| -------------------------- | ---------------------------------------------------------- | ------------------------------- |
| `bluemap.packsUrls`        | List of URLs to download BlueMap packs                     | See [values.yaml](values.yaml) |
| `bluemap.config`           | List of BlueMap configuration files                        | See [values.yaml](values.yaml) |

### Kubernetes Service parameters

| Name                      | Description                                                | Value       |
| ------------------------- | ---------------------------------------------------------- | ----------- |
| `service.type`            | BlueMap service type                                       | `ClusterIP` |
| `service.port`            | BlueMap service port                                       | `8100`      |

### Kubernetes Ingress parameters

| Name                       | Description                                                | Value                    |
| -------------------------- | ---------------------------------------------------------- | ------------------------ |
| `ingress.enabled`          | Enable ingress record generation for BlueMap               | `false`                  |
| `ingress.className`        | IngressClass that will be used to implement the Ingress    | `""`                     |
| `ingress.annotations`      | Additional annotations for the Ingress resource            | `{}`                     |
| `ingress.hosts`            | List of hosts for the Ingress                              | See [values.yaml](values.yaml) |
| `ingress.tls`              | TLS configuration for the Ingress                          | `[]`                     |

### Resource Management parameters

| Name                       | Description                                                | Value                    |
| -------------------------- | ---------------------------------------------------------- | ------------------------ |
| `resources.limits`         | The resources limits for the BlueMap container             | See [values.yaml](values.yaml) |
| `resources.requests`       | The requested resources for the BlueMap container          | See [values.yaml](values.yaml) |
| `autoscaling.enabled`      | Enable autoscaling for BlueMap deployment                  | `false`                  |
| `autoscaling.minReplicas`  | Minimum number of replicas to scale back                   | `1`                      |
| `autoscaling.maxReplicas`  | Maximum number of replicas to scale out                    | `100`                    |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage        | `80`                     |

### Storage parameters

| Name                       | Description                                                | Value                    |
| -------------------------- | ---------------------------------------------------------- | ------------------------ |
| `volumes`                  | Additional volumes for the BlueMap pod                     | See [values.yaml](values.yaml) |
| `volumeMounts`             | Additional volumeMounts for the BlueMap container          | See [values.yaml](values.yaml) |

### Other parameters

| Name                       | Description                                                | Value                    |
| -------------------------- | ---------------------------------------------------------- | ------------------------ |
| `serviceAccount.create`    | Enable creation of ServiceAccount for BlueMap pod          | `true`                   |
| `serviceAccount.name`      | The name of the ServiceAccount to use                      | `""`                     |
| `podAnnotations`           | Annotations for BlueMap pods                               | `{}`                     |
| `podLabels`                | Extra labels for BlueMap pods                              | `{}`                     |
| `nodeSelector`             | Node labels for pod assignment                             | `{}`                     |
| `tolerations`              | Tolerations for pod assignment                             | `[]`                     |
| `affinity`                 | Affinity for pod assignment                                | `{}`                     |

## Configuration

### BlueMap Configuration

BlueMap can be configured using the `bluemap.config` parameter. This parameter accepts a list of configuration files, each with a path and content. For example:

```yaml
bluemap:
  config:
    - path: "/app/config/bluemap/app.conf"
      content: |
        # BlueMap configuration file
        webserver {
          port = 8100
          bind-address = "0.0.0.0"
        }
        # More configuration options...
```

Alternatively, you can use an existing ConfigMap:

```yaml
bluemap:
  config:
    - path: "/app/config/bluemap/app.conf"
      configMap:
        name: bluemap-config
        key: app.conf
```

### BlueMap Packs

BlueMap packs can be downloaded using the `bluemap.packsUrls` parameter. This parameter accepts a list of URLs to download. For example:

```yaml
bluemap:
  packsUrls:
    - "https://github.com/TheMeinerLP/BlueMapS3Storage/releases/download/v1.4.0/BlueMapS3Storage-1.4.0.jar"
```

## Persistence

The chart mounts an emptyDir volume at `/app/config/packs` by default. To use a persistent volume, you can add a PVC to the `volumes` parameter:

```yaml
volumes:
  - name: data
    persistentVolumeClaim:
      claimName: bluemap-data
volumeMounts:
  - name: data
    mountPath: "/app/data"
```

## Accessing BlueMap

Once the chart is installed, you can access BlueMap using one of the following methods:

### ClusterIP Service (default)

```bash
kubectl port-forward svc/my-bluemap 8100:8100
```

Then access BlueMap at http://localhost:8100

### NodePort Service

Set `service.type=NodePort` in your values file, then:

```bash
export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services my-bluemap)
export NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```

### LoadBalancer Service

Set `service.type=LoadBalancer` in your values file, then:

```bash
export SERVICE_IP=$(kubectl get svc --namespace default my-bluemap --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
echo http://$SERVICE_IP:8100
```

### Ingress

Set `ingress.enabled=true` and configure `ingress.hosts` in your values file. Then access BlueMap at the configured host.