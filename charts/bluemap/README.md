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