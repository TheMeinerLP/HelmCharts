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

You can add this Helm repository in two ways:

#### Option 1: Using the GitHub Pages Helm Repository

```bash
# Add the repository
helm repo add helmcharts https://GITHUB_USERNAME.github.io/HelmCharts/
# Update the repository
helm repo update
```

Replace `GITHUB_USERNAME` with your actual GitHub username.

#### Option 2: Clone the Repository Locally

```bash
git clone https://github.com/GITHUB_USERNAME/HelmCharts.git
cd HelmCharts
```

### Installing a Chart

#### From the Helm Repository

```bash
# Search for available charts
helm search repo helmcharts

# Install a chart
helm install my-release helmcharts/chart-name
```

For example, to install the BlueMap chart:

```bash
helm install my-bluemap helmcharts/bluemap
```

#### From Local Clone

```bash
helm install my-release ./charts/chart-name
```

For more information about a specific chart, refer to its README.md file.

## Versioning

This repository uses [Semantic Versioning](https://semver.org/) for all Helm charts. Each chart is versioned independently according to semantic versioning principles:

- **Major version (X.0.0)**: Incompatible API changes
- **Minor version (0.X.0)**: Added functionality in a backward compatible manner
- **Patch version (0.0.X)**: Backward compatible bug fixes

### Automated Releases

We use [semantic-release](https://github.com/semantic-release/semantic-release) to automate the release process. The version numbers are automatically determined from commit messages following the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` - Minor release (feature addition)
- `fix:` - Patch release (bug fix)
- `docs:`, `style:`, `refactor:`, `perf:`, `test:`, `build:`, `ci:`, `chore:` - Patch release
- `BREAKING CHANGE:` or `feat!:` - Major release

Example commit messages:
```
feat(bluemap): add support for custom resource limits
fix(bluemap): correct port configuration in service
docs: update installation instructions
feat!: remove deprecated configuration options
```

Each chart has its own versioning and release cycle. When changes are pushed to the main branch, the affected charts are automatically versioned and released.

## Helm Repository on GitHub Pages

This repository uses GitHub Pages to host a Helm repository. The Helm charts are automatically packaged and published to GitHub Pages when changes are pushed to the main branch.

### How It Works

1. Two GitHub Actions workflows run when changes are pushed to the `main` branch:
   - The semantic release workflow (`sematic-releases.yml`) updates chart versions based on commit messages
   - The chart releaser workflow (`chart-release.yml`) packages and publishes the charts
2. The chart releaser workflow uses the official [helm/chart-releaser-action@v1.6.0](https://github.com/helm/chart-releaser-action) to:
   - Package all Helm charts in the `charts/` directory
   - Create GitHub releases for each chart version
   - Generate a Helm repository index file
   - Publish the packaged charts and index file to the `gh-pages` branch
3. GitHub Pages serves the content of the `gh-pages` branch as a website

### Setting Up GitHub Pages

If you're forking this repository, you'll need to set up GitHub Pages:

1. Go to your repository on GitHub
2. Click on "Settings"
3. Scroll down to the "GitHub Pages" section
4. Select the `gh-pages` branch as the source
5. Click "Save"

The Helm repository will be available at `https://YOUR_USERNAME.github.io/HelmCharts/`.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Issue and Pull Request Workflow

We use GitHub Issues and Pull Requests to manage changes and improvements to this repository. To help maintain organization and efficiency, we've implemented the following workflow:

#### Issue Templates

When creating a new issue, please use one of the provided templates:

- **Bug Report**: For reporting bugs or unexpected behavior in the charts
- **Feature Request**: For suggesting new features or enhancements
- **Documentation Change**: For suggesting improvements to documentation

Each template includes specific fields to help you provide all the necessary information.

#### Pull Request Template

When submitting a pull request, please fill out the PR template with:

- A clear description of your changes
- Links to related issues
- The type of change (bug fix, feature, etc.)
- Testing information
- Any additional context that might be helpful

#### Project Board Automation

All new issues and pull requests are automatically added to our [project board](https://github.com/orgs/OneLiteFeatherNET/projects/1), where they go through the following stages:

1. **To Do**: New issues that need to be triaged
2. **In Progress**: Issues that are being worked on
3. **Review**: Pull requests that need review
4. **Done**: Completed issues and merged pull requests

This helps us track the status of all work and ensure nothing falls through the cracks.

### Adding a New Chart

To add a new chart to this repository:

1. Create a new directory under `charts/` with your chart name
   ```bash
   mkdir -p charts/your-chart-name
   ```

2. Initialize a new Helm chart or copy your existing chart into this directory
   ```bash
   # Initialize a new chart
   helm create charts/your-chart-name
   
   # OR copy an existing chart
   cp -r /path/to/your/chart/* charts/your-chart-name/
   ```

3. Add a `.releaserc.json` file to your chart directory to configure semantic-release
   ```bash
   cp charts/bluemap/.releaserc.json charts/your-chart-name/
   ```

4. Create a `CHANGELOG.md` file for your chart
   ```bash
   cat > charts/your-chart-name/CHANGELOG.md << EOF
   # Changelog
   
   All notable changes to this chart will be documented in this file.
   
   The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
   and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
   
   ## [Unreleased]
   
   ### Added
   - Initial chart release
   EOF
   ```

5. No need to update any workflow files - the semantic release workflow (`sematic-releases.yml`) automatically detects new charts in the `charts/` directory, and the chart releaser workflow (`chart-release.yml`) automatically packages and publishes all charts.

6. Commit and push your changes
   ```bash
   git add .
   git commit -m "feat: add your-chart-name chart"
   git push
   ```

The GitHub Actions workflows will automatically:
- Process your chart for semantic versioning (using semantic-release)
- Create GitHub releases for each chart version
- Package your chart (using helm/chart-releaser-action)
- Update the Helm repository index
- Publish your chart to GitHub Pages

### Commit Messages

When contributing, please follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for your commit messages to ensure proper versioning.

## License

This project is licensed under the terms of the [LICENSE](./LICENSE) file.