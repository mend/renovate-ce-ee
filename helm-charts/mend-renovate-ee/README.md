# Mend Renovate Installation - Helm

## Add Helm repository

```shell
helm repo add mend-renovate-ce-ee https://mend.github.io/renovate-ce-ee
helm repo update
```

## Install Renovate chart

```shell
helm install --generate-name --set renovateWorker.config='\{\"token\":\"...\"\}' mend-renovate-ce-ee/mend-renovate-enterprise-edition
```

See [Configuration Options](https://github.com/mend/renovate-ce-ee/blob/main/docs/configuration-options.md) for more information.
