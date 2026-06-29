# Mend Remediate — Classic Repository Integrations

## Migrating from Classic Remediate to Renovate Enterprise Edition

> [!NOTE]
> The Mend Remediate integration is currently a **Beta** release.

Starting with **Renovate Enterprise Edition 14.8.0**, Mend Remediate is built directly into Renovate Enterprise Edition. This integration lets you combine the full capabilities of Mend Remediate with those of Renovate Enterprise Edition in a single product.

### What stays the same

The runtime and end-user experience is designed to be seamless: your existing user-level configuration continues to work without interruption.

### What changes

The main difference is how the Docker container is configured.

#### 1. The `prop.json` file is no longer supported

Configuration that previously lived in `prop.json` now moves to environment variables:

- **Activation key** — passed as an environment variable.
- **Proxy** — uses the native environment proxy settings: `HTTP_PROXY`, `HTTPS_PROXY`, and `NO_PROXY`.
- **Controller URL** — passed via the `MEND_RNV_REMEDIATE_CONTROLLER_URL` environment variable.

#### 2. Renamed configuration

- `WS_HOST_RULES_PRIVATE_KEY` must be migrated to `RENOVATE_PRIVATE_KEY` (see Renovate [privatekey](https://docs.renovatebot.com/self-hosted-configuration/#privatekey) config options).

#### 3. Removed and deprecated behavior

- Single-container mode (combined server and worker in one container) is no longer supported.
- Job scheduling now follows the Renovate Enterprise Edition documentation only. scheduling through the controller is no longer used.
- The `checkRedisConnection` step at server startup is no longer supported.
- The `MC_API_SECRET_STATIC` config option is no longed available. see the Renovate Enterprise Edition [docs](./configuration-options.md#job-scheduling-options) .

#### 4. Updated APIs

- The `/status` API now follows the Renovate Enterprise Edition specification.

### New environment variables

The following environment variables have been added to Renovate Enterprise Edition as part of this change:

| Variable | Purpose |
| --- | --- |
| `MEND_RNV_ACTIVATION_KEY` | Activation key for Mend Remediate. |
| `MEND_RNV_REMEDIATE_SERVER_SECRET` | Server secret used by Remediate. |
| `MEND_RNV_REMEDIATE_CONTROLLER_URL` | URL of the Remediate controller. |

