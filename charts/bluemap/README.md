# BlueMap Helm Chart

This Helm chart deploys BlueMap, a 3D map viewer for Minecraft.

## Installation

### Using Helm

Add the Helm repository and install the chart:

```bash
helm repo add helmcharts https://themeinerlp.github.io/HelmCharts/
helm repo update
helm install bluemap helmcharts/bluemap
```

### Using Flux CD

To deploy BlueMap using Flux CD, create a HelmRelease resource:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: bluemap
  namespace: bluemap
spec:
  chart:
    spec:
      chart: bluemap
      sourceRef:
        kind: HelmRepository
        name: helmcharts
        namespace: flux-system
      version: ">=1.0.0"
  interval: 1m0s
  values:
    # Your custom values here
```

## Configuration

### ConfigMaps

The chart supports configuring BlueMap through ConfigMaps. You can either:

1. Provide the configuration content directly in the `values.yaml` file:

```yaml
bluemap:
  config:
    - path: "/app/config/bluemap/app.conf"
      content: |
        # BlueMap configuration file
        webserver {
          port: 8100
          bind-address: "0.0.0.0"
          accept-remote-connections: true
        }
        # ... more configuration ...
```

2. Reference an existing ConfigMap:

```yaml
bluemap:
  config:
    - path: "/app/config/bluemap/app.conf"
      configMap:
        name: my-bluemap-config
        key: app.conf
```

### Packs

You can specify BlueMap packs to be downloaded and installed:

```yaml
bluemap:
  packs:
    - "https://github.com/BlueMap-Minecraft/BlueMapPack/releases/download/v1.0.0/BlueMapPack-1.0.0.jar"
```

## Usage Examples

### Production Deployment with Flux CD

Here's a complete example showing how to deploy BlueMap in a production environment with all features:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: bluemap
  namespace: bluemap
spec:
  chart:
    spec:
      chart: bluemap
      sourceRef:
        kind: HelmRepository
        name: helmcharts
        namespace: flux-system
      version: "=1.0.5"
  install:
    remediation:
      retries: 0
  interval: 1m0s
  values:
    # Resource configuration for production workloads
    resources:
      limits:
        cpu: 2000m
        memory: "1Gi"
      requests:
        cpu: 500m
        memory: ".5Gi"
    
    # High availability with multiple replicas
    replicaCount: 3
    
    # Mount volumes from Secrets and ConfigMaps
    volumes:
      - name: s3-conf
        secret:
          secretName: s3-conf
      - name: bluemap-maps
        configMap:
          name: bluemap-maps
    
    volumeMounts:
      - name: s3-conf
        readOnly: true
        mountPath: "/app/config/storages/"
      - name: bluemap-maps
        mountPath: /app/config/maps/world.conf
        subPath: world.conf
      - name: bluemap-maps
        mountPath: /app/config/maps/world_nether.conf
        subPath: world_nether.conf
      - name: bluemap-maps
        mountPath: /app/config/maps/world_the_end.conf
        subPath: world_the_end.conf
      - name: bluemap-maps
        mountPath: /app/config/maps/world_op.conf
        subPath: world_op.conf
      - name: bluemap-maps
        mountPath: /app/config/maps/world_op_nether.conf
        subPath: world_op_nether.conf
    
    # Install BlueMap extensions/packs
    bluemap:
      packs:
        - https://github.com/TheMeinerLP/BlueMapS3Storage/releases/download/v1.4.0/BlueMapS3Storage-1.4.0.jar
      config:
        - path: "/app/config/core.conf"
          configMap:
            name: bluemap-config
            key: core.conf
    
    # Ingress with TLS
    ingress:
      enabled: true
      hosts:
        - host: bluemap.example.com
          paths:
            - path: /
              pathType: Prefix
      tls:
        - secretName: bluemap-tls
          hosts:
            - bluemap.example.com
```

### Flux CD with Kustomize

For a GitOps approach using Flux CD with Kustomize to manage ConfigMaps and Secrets:

#### Directory Structure

```
apps/
├── base/
│   └── bluemap/
│       ├── kustomization.yaml
│       └── release.yaml
└── clusters/
    └── production/
        └── bluemap/
            ├── kustomization.yaml
            ├── release.yaml (patch)
            ├── core.conf
            ├── s3.conf
            └── maps/
                ├── world.conf
                ├── world_nether.conf
                └── world_the_end.conf
```

#### Base HelmRelease (`apps/base/bluemap/release.yaml`)

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: bluemap
  namespace: bluemap
spec:
  chart:
    spec:
      chart: bluemap
      sourceRef:
        kind: HelmRepository
        name: helmcharts
        namespace: flux-system
      version: ">=1.0.0"
  interval: 1m0s
  values:
    replicaCount: 1
```

#### Cluster-Specific Kustomization (`apps/clusters/production/bluemap/kustomization.yaml`)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: bluemap
generatorOptions:
  disableNameSuffixHash: true
resources:
  - ../../../base/bluemap/
patches:
  - path: release.yaml

# Generate ConfigMaps from local files
configMapGenerator:
  - name: bluemap-config
    files:
      - core.conf
  - name: bluemap-maps
    files:
      - maps/world.conf
      - maps/world_nether.conf
      - maps/world_the_end.conf

# Generate Secrets from local files (use SOPS for encryption)
secretGenerator:
  - name: s3-conf
    files:
      - s3.conf
  - name: bluemap-tls
    type: kubernetes.io/tls
    files:
      - tls.crt
      - tls.key
```

#### HelmRelease Patch (`apps/clusters/production/bluemap/release.yaml`)

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: bluemap
  namespace: bluemap
spec:
  values:
    replicaCount: 3
    resources:
      limits:
        cpu: 2000m
        memory: "1Gi"
      requests:
        cpu: 500m
        memory: ".5Gi"
    
    volumes:
      - name: s3-conf
        secret:
          secretName: s3-conf
      - name: bluemap-maps
        configMap:
          name: bluemap-maps
    
    volumeMounts:
      - name: s3-conf
        readOnly: true
        mountPath: "/app/config/storages/"
      - name: bluemap-maps
        mountPath: /app/config/maps/world.conf
        subPath: world.conf
      - name: bluemap-maps
        mountPath: /app/config/maps/world_nether.conf
        subPath: world_nether.conf
      - name: bluemap-maps
        mountPath: /app/config/maps/world_the_end.conf
        subPath: world_the_end.conf
    
    bluemap:
      packs:
        - https://github.com/TheMeinerLP/BlueMapS3Storage/releases/download/v1.4.0/BlueMapS3Storage-1.4.0.jar
      config:
        - path: "/app/config/core.conf"
          configMap:
            name: bluemap-config
            key: core.conf
    
    ingress:
      enabled: true
      hosts:
        - host: bluemap.example.com
          paths:
            - path: /
              pathType: Prefix
      tls:
        - secretName: bluemap-tls
          hosts:
            - bluemap.example.com
```

**Benefits of this approach:**
- **Separation of concerns**: Base configuration is separate from environment-specific settings
- **GitOps-friendly**: All configuration files are stored in Git
- **Automatic ConfigMap/Secret generation**: Kustomize generates ConfigMaps and Secrets from files
- **No hash suffixes**: `disableNameSuffixHash: true` ensures predictable resource names
- **SOPS integration**: Encrypt sensitive files before committing to Git (recommended for secrets)

### Simple Deployment with Helm

For a basic deployment using Helm directly:

```bash
helm install bluemap helmcharts/bluemap \
  --set replicaCount=1 \
  --set resources.limits.cpu=1000m \
  --set resources.limits.memory=512Mi \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=bluemap.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

### Advanced Configuration Features

#### Understanding Volume Mapping

Volume mapping is essential for injecting configuration files and sensitive data into the BlueMap container. The Helm chart uses a two-step process:

1. **Define Volumes** (`volumes`): Declares which ConfigMaps or Secrets should be available to the pod
2. **Mount Volumes** (`volumeMounts`): Specifies where these volumes should be mounted inside the container filesystem

This separation allows you to:
- Keep sensitive data (credentials, TLS certificates) in Kubernetes Secrets
- Store configuration files in ConfigMaps for easy version control
- Mount specific files from ConfigMaps/Secrets to precise locations using `subPath`
- Update configurations without rebuilding container images

**Why use `subPath`?**
The `subPath` parameter allows you to mount individual files from a ConfigMap or Secret instead of mounting the entire volume. This is crucial when you need to place multiple configuration files in different locations or when you want to mount specific files without overwriting the entire directory.

#### Using External Secrets

Mount sensitive configuration from Kubernetes Secrets:

```yaml
volumes:
  - name: s3-credentials
    secret:
      secretName: s3-credentials

volumeMounts:
  - name: s3-credentials
    readOnly: true
    mountPath: "/app/config/storages/"
```

#### Multiple World Configurations

Configure multiple Minecraft worlds using ConfigMaps:

```yaml
volumes:
  - name: bluemap-maps
    configMap:
      name: bluemap-maps

volumeMounts:
  - name: bluemap-maps
    mountPath: /app/config/maps/world.conf
    subPath: world.conf
  - name: bluemap-maps
    mountPath: /app/config/maps/world_nether.conf
    subPath: world_nether.conf
  - name: bluemap-maps
    mountPath: /app/config/maps/world_the_end.conf
    subPath: world_the_end.conf
```

#### Installing Custom Packs

Add BlueMap extensions or storage providers:

```yaml
bluemap:
  packs:
    - https://github.com/TheMeinerLP/BlueMapS3Storage/releases/download/v1.4.0/BlueMapS3Storage-1.4.0.jar
    - https://example.com/custom-pack.jar
```

## Configuration Values

### Common Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas for high availability | `1` |
| `image.repository` | BlueMap container image repository | `ghcr.io/bluemap-minecraft/bluemap` |
| `image.tag` | BlueMap container image tag | `v5.11` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `resources.limits.cpu` | CPU resource limits | `500m` |
| `resources.limits.memory` | Memory resource limits | `1Gi` |
| `resources.requests.cpu` | CPU resource requests | `100m` |
| `resources.requests.memory` | Memory resource requests | `.5Gi` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `8100` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress controller resource | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.hosts` | Ingress host configuration | `[{host: "chart-example.local", paths: [{path: "/", pathType: "ImplementationSpecific"}]}]` |
| `ingress.tls` | Ingress TLS configuration | `[]` |

### Volumes and Mounts

| Parameter | Description | Default |
|-----------|-------------|---------|
| `volumes` | Additional volumes for the pod | `[]` |
| `volumeMounts` | Additional volume mounts for the container | `[]` |

### BlueMap Specific Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `bluemap.packs` | List of BlueMap pack URLs to download and install | `[]` |
| `bluemap.config` | BlueMap configuration files (from ConfigMaps or inline content) | `[]` |

### Other Values

For a complete list of all available values, see the [`values.yaml`](./values.yaml) file.

## Versioning

This chart follows [Semantic Versioning](https://semver.org/). The version is automatically updated based on the changes made to the chart using [semantic-release](https://github.com/semantic-release/semantic-release).

### Version History

For a full list of changes for each version, see the [CHANGELOG.md](./CHANGELOG.md) file.

### Contributing

When contributing to this chart, please follow the [Conventional Commits](https://www.conventionalcommits.org/) specification in your commit messages to ensure proper versioning:

- `feat(bluemap): ...` - For new features (minor version bump)
- `fix(bluemap): ...` - For bug fixes (patch version bump)
- `feat(bluemap)!: ...` or including `BREAKING CHANGE:` in the commit body - For breaking changes (major version bump)

The chart version in `Chart.yaml` will be automatically updated by the CI/CD pipeline based on your commit messages.