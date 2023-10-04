# Mend Renovate Installation - Helm

## Add Helm repository

```shell
helm repo add renovate-ce https://mend.github.io/renovate-ce-ee
helm repo update
```

## Install Renovate chart

```shell
helm install --generate-name --set renovate.config='\{\"token\":\"...\"\}' renovate-ce-ee/renovate-ce
```

See the [docs](<[https://github.com/mend/renovate-ce-ee/blob/main/helm-charts/mend-renovate/values.yaml](https://github.com/mend/renovate-cc-ee/tree/main/docs)>) for further configuration.
