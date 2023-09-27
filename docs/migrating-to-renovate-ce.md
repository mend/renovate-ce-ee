# Migrating from Renovate On-Premise to Renovate Community Edition
When migrating from Renovate On-Premise to Renovate Community Edition, you can continue to use the same Bot/User, with just a couple of modifications. Alternatively, you can create a separate Bot/User for the Renovate CE and disable/remove the original Renovate On-Premise Bot when you are ready.

## Change to the Environment Variables
Some existing environment variables have been renamed, and some new ones have been added.

See the specific configuration instructions ([GitHub](./configuration-github.md), [GitLab](./configuration-gitlab.md)) to learn more about the variables mentioned below.

### Common variables
| Renovate On-Premise    | Renovate Community Edition |
|------------------------|--|
| ACCEPT_WHITESOURCE_TOS | MEND_ACCEPT_TOS |
| LICENSE_KEY            | MEND_LICENSE_KEY |
| RENOVATE_PLATFORM      | MEND_RNV_PLATFORM |
| RENOVATE_ENDPOINT      | MEND_RNV_GITHUB_ENDPOINT |
| SCHEDULER_CRON         | MEND_RNV_CRON_JOB_SCHEDULER |
| [New]                  | MEND_RNV_CRON_APP_SYNC |
| [New]                  | MEND_RNV_ADMIN_API_ENABLED |
| [New]                  | MEND_RNV_SERVER_API_SECRET |
| [New]                  | MEND_RNV_SQLITE_FILE_PATH |

### Variables specific to GitHub instances
| Renovate On-Premise EnvVars | Renovate Community Edition |
|--|--|
| RENOVATE_ENDPOINT | MEND_RNV_GITHUB_ENDPOINT |
| GITHUB_APP_ID | MEND_RNV_GITHUB_APP_ID |
| GITHUB_APP_KEY | MEND_RNV_GITHUB_APP_KEY |
| WEBHOOK_SECRET | MEND_RNV_GITHUB_WEBHOOK_SECRET |

### Variables specific to GitLab instances
| Renovate On-Premise EnvVars | Renovate Community Edition |
|--|--|
| RENOVATE_ENDPOINT | MEND_RNV_GITLAB_ENDPOINT |
| RENOVATE_TOKEN | MEND_RNV_GITLAB_PAT |
| WEBHOOK_SECRET | MEND_RNV_GITLAB_WEBHOOK_SECRET |

## Changes to Bot Configuration
The only changes required to the Renovate Bot GitHub App or GitLab Account settings are to ensure that the webhook URL points to the new running instance of Renovate Community Edition. (Alternatively, you can create a new GitHub App or GitLab User for the new instance.)
If the URL and host port of the server have not changed, there will be no need to make any changes to the App/Bot configuration.

_Note: The default ports have changed from port 80 to port 3000_
### GitHub App configuration changes
Set the Webhook URL to point to the Renovate Community Edition server, with `/webhook` at the end.

### GitLab System/Repo configuration changes
Set the System Hook URL to point to the Renovate Community Edition server, with `/webhook` at the end.
Also, in each onboarded repository, set the Webhook URL with “Issue” event to point to the same URL.
