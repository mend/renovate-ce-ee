# Mend Renovate Installation - Helm

## Add Helm repository

```shell
helm repo add renovate-on-prem https://mend.github.io/renovate-on-prem
helm repo update
```

## Install Renovate chart

```shell
helm install --generate-name --set renovate.config='\{\"token\":\"...\"\}' renovate-on-prem/whitesource-renovate
```

See the available [values](../helm-charts/whitesource-renovate/values.yaml) for full configuration and review configuration guides for [GitHub](./configuration-github.md) and/or [GitLab](./configuration-gitlab.md).
