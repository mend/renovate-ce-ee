# Renovate Pro Configuration

## Provision GitHub Enterprise App

Before running Renovate Pro, you need to provision it as an App on GitHub Enterprise, and retrieve the ID + private key provided. This requires GitHub Enterprise 2.12 or later. Name the app "Renovate" so that it shows up as "renovate[bot]" in Pull Requests and can be recognised when GitHub sends webhooks.

Be sure to enter a webhook secret when adding the app. If you don't care about a secret, then enter 'renovate'.

## Configure Renovate Pro

Renovate Pro requires configuration via environment variables in addition to Renovate OSS's regular configuration:

**`LICENSE_ACCEPT`**: Renovate Pro will not run unless you accept the terms of the [Renovate User Agreement](https://renovatebot.com/user-agreement) by setting this environment variable to `y`. This is required whether you are running Renovate Pro in commercial or evaluation mode.

**`LICENSE_MODE`**: If you have purchased a commercial license for Renovate Pro then you need to set this value to `commercial` to enable more than 3 repositories and remove the evaluation mode banner from PRs. Leave this field empty to default to evaluation mode.

**`LICENSE_NAME`**: To enable commercial mode, you also need to also fill in the company name that the license is registered to. It should match what you entered in the order form. Leave empty for evaluation mode.

**`GITHUB_ENDPOINT`**: This is the API endpoint for your GitHub Enterprise installation.

**`GITHUB_APP_ID`**: The GitHub App ID provided by GitHub Enterprise when you provisioned the Renovate app.

**`GITHUB_APP_KEY`**: A string representation of the private key provided by GitHub Enterprise when you provisioned Renovate. To insert the value directly into a Docker Compose environment variable, open the PEM file in a text editor and replace all new lines with "\n" so that the entire key is on one line. Alternatively, you can skip setting this key as an environment variable and instead mount it as a file to `/usr/src/app/renovate.private-key.pem`, as shown in the example Docker Compose file.

**`GITHUB_COM_TOKEN`**: A Personal Access Token for a user account on github.com (i.e. *not* an account on your GitHub Enterprise instance). This is used for retrieving changelogs and release notes from repositories hosted on github.com and it does not matter who it belongs to. It needs only read-only access privileges. Note: do not configure `GITHUB_TOKEN`.

**`WEBHOOK_SECRET`**: This configuration option must be set unless you configured it to 'renovate', which is default.

**`SCHEDULER_CRON`**: This configuration option accepts a 5-part cron schedule and is *optional*. It defaults to `0 * * * *` (i.e. once per hour exactly on the hour) if it is unset. If decreasing the interval then be careful that you do not exhaust the available hourly rate limit of the app on GitHub Enterprise or cause too much load.

## Configure Renovate Core

The core Renovate OSS functionality can be configured using environment variables (e.g. `RENOVATE_XXXXXX`) or via a `config.js` file that you mount inside the Renovate Pro container to `/usr/src/webapp/config.js`.
