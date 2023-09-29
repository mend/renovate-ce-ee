# Mend Renovate Installation - Helm

## Add Helm repository

```shell
helm repo add renovate-ce https://mend.github.io/renovate-ce-ee
helm repo update
```

## Install Renovate chart

```shell
helm install --generate-name --set renovate.config='\{\"token\":\"...\"\}' renovate-cc-ee/whitesource-renovate
```

See the available [values](../helm-charts/whitesource-renovate/values.yaml) for full configuration and review configuration guides for [GitHub](./configuration-github.md) and/or [GitLab](./configuration-gitlab.md).
