# Renovate Pro Configuration

## Provision GitHub Enterprise App

Before running Renovate Pro, you need to provision it as an App on GitHub Enterprise, and retrieve the ID + private key provided. This requires GitHub Enterprise 2.12 or later. Name the app "Renovate" so that it shows up as "renovate[bot]" in Pull Requests and can be recognised when GitHub sends webhooks.

The App requires the following permissions:

* Repository metadata: Read-only
* Repository administration: Read-only
* Commit statuses: Read & write
* Issues: Read & write
* Pull Requests: Read & write
* Repository contents: Read & write

It should subscribe to the following events:

* Repository
* Status
* Pull request
* Push

Description, Homepage, User authorization callback URL, and Setup URL are all unimportant so you may set them to whatever you like.

The Renovate Pro webhook listener binds to port 8080 by default, however it will bind to `process.env.PORT` instead if that is defined. Note: The Renovate Pro image takes care of exposing port 8080 of the container, so if you change this port then you will need to take care of any exposing/mapping of ports yourself. In the [Docker Compose example config](https://github.com/renovatebot/pro/blob/master/examples/docker-compose.yml), the default port 8080 is used but then mapped to port 80 on the host.

For the Webhook URL field, point it to `/webhook` on port 80 (or whatever port you mapped to) of the server that you will run Renovate Pro on, e.g. http://1.2.3.4/webhook
Be sure to enter a webhook secret too. If you don't care about the value, then enter 'renovate' as that is the default secret that the webhook handler process uses.

You can use the [Renovate icon](https://renovatebot.com/images/icon.png) for the app/bot if you desire.

## Configure Renovate Pro

Renovate Pro requires configuration via environment variables in addition to Renovate OSS's regular configuration:

**`ACCEPT_AGREEMENT`**: Renovate Pro will not run unless you accept the terms of the [Renovate User Agreement](https://renovatebot.com/user-agreement) by setting this environment variable to `y`. This is required whether you are running Renovate Pro in commercial or evaluation mode.

**`LICENSE_MODE`**: If you have purchased a commercial license for Renovate Pro then you need to set this value to `commercial` to enable more than 3 repositories and remove the evaluation mode banner from PRs. Leave this field empty to default to evaluation mode.

**`LICENSE_NAME`**: To enable commercial mode, you also need to also fill in the company name that the license is registered to. It should match what you entered in the order form. Leave empty for evaluation mode.

**`GITHUB_ENDPOINT`**: This is the API endpoint for your GitHub Enterprise installation.

**`GITHUB_APP_ID`**: The GitHub App ID provided by GitHub Enterprise when you provisioned the Renovate app.

**`GITHUB_APP_KEY`**: A string representation of the private key provided by GitHub Enterprise when you provisioned Renovate. To insert the value directly into a Docker Compose environment variable, open the PEM file in a text editor and replace all new lines with "\n" so that the entire key is on one line. Alternatively, you can skip setting this key as an environment variable and instead mount it as a file to `/usr/src/app/renovate.private-key.pem`, as shown in the example Docker Compose file.

**`GITHUB_COM_TOKEN`**: A Personal Access Token for a user account on github.com (i.e. _not_ an account on your GitHub Enterprise instance). This is used for retrieving changelogs and release notes from repositories hosted on github.com and it does not matter who it belongs to. It needs only read-only access privileges. Note: do not configure `GITHUB_TOKEN`.

**`WEBHOOK_SECRET`**: This configuration option must be set unless you configured it to 'renovate', which is default.

**`SCHEDULER_CRON`**: This configuration option accepts a 5-part cron schedule and is _optional_. It defaults to `0 * * * *` (i.e. once per hour exactly on the hour) if it is unset. If decreasing the interval then be careful that you do not exhaust the available hourly rate limit of the app on GitHub Enterprise or cause too much load.

## Configure Renovate Core

The core Renovate OSS functionality can be configured using environment variables (e.g. `RENOVATE_XXXXXX`) or via a `config.js` file that you mount inside the Renovate Pro container to `/usr/src/webapp/config.js`.


**npm Registry** If using your own npm registry, you may find it easiest to update your `docker-compose.yml` to include a volume that maps an `.npmrc` file to `/home/node/.npmrc`. The RC file should contain `registry=...` with the registry URL your company uses internally. This will allow Renovate to find shared configs and other internally published packages.
