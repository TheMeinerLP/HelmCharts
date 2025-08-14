# BlueMap Helm Chart

This Helm chart deploys BlueMap, a 3D map viewer for Minecraft.

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

## Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `ghcr.io/bluemap-minecraft/bluemap` |
| `image.tag` | Image tag | `v5.11` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `bluemap.config` | BlueMap configuration | See `values.yaml` |
| `bluemap.packs` | BlueMap packs to install | See `values.yaml` |

For more values, see the `values.yaml` file.