# Helm Charts Repository

This repository contains a collection of Helm charts for various applications.

## Available Charts

### [BlueMap](./charts/bluemap)

A Helm chart for deploying [BlueMap](https://github.com/BlueMap-Minecraft/BlueMap), a Minecraft map renderer and web viewer, on a Kubernetes cluster.

## Usage

### Prerequisites

- Kubernetes 1.14+
- Helm 3.0+

### Adding the Repository

To use the charts in this repository, you can clone it locally:

```bash
git clone https://github.com/yourusername/HelmCharts.git
cd HelmCharts
```

### Installing a Chart

To install a chart from this repository:

```bash
helm install my-release ./charts/chart-name
```

For example, to install the BlueMap chart:

```bash
helm install my-bluemap ./charts/bluemap
```

For more information about a specific chart, refer to its README.md file.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the terms of the [LICENSE](./LICENSE) file.