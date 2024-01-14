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

See the [docs](<[https://github.com/mend/renovate-cc-ee/tree/main/docs](https://github.com/mend/renovate-cc-ee/tree/main/docs)>) for further configuration.
