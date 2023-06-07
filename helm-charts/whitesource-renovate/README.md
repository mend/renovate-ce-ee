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

> See the [docs]([https://github.com/mend/renovate-on-prem/blob/main/helm-charts/whitesource-renovate/values.yaml](https://github.com/mend/renovate-on-prem/tree/main/docs)) for further configuration.
