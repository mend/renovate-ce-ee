# Mend Renovate Installation

## Choice of image type

Renovate CE comes with both the default image (e.g. `ghcr.io/mend/renovate-ce:6.0.0`) and a "full" image (e.g. `ghcr.io/mend/renovate-ce:6.0.0-full`).

The default image is optimized for size and only contains the core Renovate functionality.
It is intended for use with Renovate's `binarySource=install` capability, which dynamically selects and installs third party tools at runtime.

The full image contains preinstalled third-party tools (e.g. Python, Poetry, Node.js, Gradle, etc.) so that you can run Renovate with `binarySource=global` and not require any dynamic runtime installation.

Renovate On-Premises (v5 and earlier) was built with a "full" image only, so if upgrading from an earlier version you may want to use the full image for compatibility.

## Installation using Helm

### Add Helm repository

```shell
helm repo add mend-renovate-ce-ee https://mend.github.io/renovate-ce-ee
helm repo update
```

### Install Renovate chart

```shell
helm install --generate-name --set renovate.config='\{\"token\":\"...\"\}' mend-renovate-ce-ee/mend-renovate-ce
```

See the available [values](../helm-charts/mend-renovate-ce/values.yaml) for full configuration and review configuration guides for [GitHub](setup-for-github.md), [GitLab](setup-for-gitlab.md) or [Bitbucket](setup-for-bitbucket.md).

