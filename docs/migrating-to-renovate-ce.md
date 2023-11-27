# Migrating from Renovate On-Premises to Renovate Community Edition

When migrating from Renovate On-Premises to Renovate Community Edition, you can continue to use the same Bot/User, with just a couple of modifications.

## Health Check

If you are using a "health check" of the Renovate container then you should point it to `/health` in Renovate CE.

## Environment Variable Renaming

Some existing environment variables have been renamed, and some new ones have been added.

See the specific configuration instructions ([GitHub](./configure-renovate-ce-github.md), [GitLab](./configure-renovate-ee-gitlab.md)) to learn more about the variables mentioned below.

### Environment Variable Key Migration

| Renovate On-Premises   | Renovate Community Edition |
|------------------------|--|
| ACCEPT_WHITESOURCE_TOS | MEND_RNV_ACCEPT_TOS |
| LICENSE_KEY            | MEND_RNV_LICENSE_KEY |
| PORT                   | MEND_RNV_SERVER_PORT |
| RENOVATE_PLATFORM      | MEND_RNV_PLATFORM |
| RENOVATE_ENDPOINT      | MEND_RNV_ENDPOINT |
| SCHEDULER_CRON         | MEND_RNV_CRON_JOB_SCHEDULER |
| WEBHOOK_SECRET         | MEND_RNV_WEBHOOK_SECRET |

### Repository auto-discovery
> [!WARNING]  
> The Renovate CLI `autodiscover` configuration option is disabled at the client level. 
Repository filtering should solely rely on server-side filtering using MEND_RNV_AUTODISCOVER_FILTER

### Variables specific to GitHub instances
| Renovate On-Premises EnvVars | Renovate Community Edition |
|--|--|
| GITHUB_APP_ID | MEND_RNV_GITHUB_APP_ID |
| GITHUB_APP_KEY | MEND_RNV_GITHUB_APP_KEY |

### Variables specific to GitLab instances

| Renovate On-Premises EnvVars | Renovate Community Edition |
|--|--|
| RENOVATE_TOKEN | MEND_RNV_GITLAB_PAT |
