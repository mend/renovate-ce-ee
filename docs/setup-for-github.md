# Configuration - Mend Renovate Community Edition for GitHub

## Create and Configure the GitHub App (bot)

Before running Mend Renovate, you need to provision it as an App on GitHub, and retrieve the ID + private key provided.

If you're running a self-hosted instance of GitHub Enterprise, it is suggested to name the app "Renovate" so that it shows up as easily recognizable as "renovate[bot]" in Pull Requests.
If you're running against `github.com` then the name Renovate is already taken by the hosted Mend Renovate app, so you will need something else like "YourCompany Renovate".

The App requires the following permissions:

- Repository permissions
  - Administration: Read-only
  - Checks: Read & write
  - Commit statuses: Read & write
  - Contents: Read & write
  - Dependabot alerts: Read-only (optional)
  - Issues: Read & write
  - Metadata: Read-only
  - Pull Requests: Read & write
  - Workflows: Read & write
- Organization permissions
  - Members: Read-only

The App should also subscribe to the following webhook events:

- Security Advisory
- Check run
- Check suite
- Issues
- Pull request
- Push
- Repository
- Status

Description, Homepage, User authorization callback URL, and Setup URL are all unimportant so you may set them to whatever you like.

The Mend Renovate webhook listener binds to port 8080 by default, however it will bind to `process.env.PORT` instead if that is defined.
Note: The Mend Renovate image takes care of exposing port 8080 of the container, so if you change this port then you will need to take care of any exposing/mapping of ports yourself.
In the [Docker Compose example config](https://github.com/mend/renovate-cc-ee/tree/main/examples/), the default port 8080 is used and then mapped to port 80 on the host.

For the Webhook URL field, point it to `/webhook` on port 80 (or whatever port you mapped to) of the server that you will run Mend Renovate on, e.g. http://1.2.3.4/webhook
Be sure to enter a webhook secret too.
If you don't care about the value, then enter 'renovate' as that is the default secret that the webhook handler process uses.

You can use the [Renovate icon](https://docs.renovatebot.com/assets/images/logo.png) for the app/bot if you desire.

## Run Mend Renovate

You can run Mend Renovate from a Docker command line prompt, or by using a Docker Compose file. Examples are provided in the links below.

**Example Docker Compose files:**

- [Mend Renovate Community Edition (GitHub)](../examples/docker-compose/renovate-ce.yml)
- [Mend Renovate Enterprise Edition (GitHub)](../examples/docker-compose/renovate-ee.yml)

> [!NOTE]
> 
> Some configuration of environment variables will be required inside the Docker Compose files.
> 
> Essential configuration options are shown below. For a full list of configurable variables, see [Configuration Options](configuration-options.md).

## Configure Environment Variables

### Essential Configuration for Mend Renovate

**`MEND_RNV_ACCEPT_TOS`**: Set this environment variable to `y` to consent to [Mend's Terms of Service](https://www.mend.io/terms-of-service/).

**`MEND_RNV_LICENSE_KEY`**: Register for a free Community Edition license key at https://www.mend.io/renovate-community/. For an Enterprise License key, contact Mend at http://mend.io.

**`MEND_RNV_PLATFORM`**: Set this to `github`.

**`MEND_RNV_GITHUB_APP_ID`**: The GitHub App ID of the provisioned Renovate app on GitHub.

**`MEND_RNV_GITHUB_APP_KEY`**: The private key of the Renovate app on GitHub. Alternatively, use `MEND_RNV_GITHUB_PEM_FILE_PATH`.

**`MEND_RNV_GITHUB_PEM_FILE_PATH`**: The file path for a GitHub app key PEM file. Defaults to `/usr/src/app/renovate.private-key.pem`. Alternatively, use `MEND_RNV_GITHUB_APP_KEY`.

**`MEND_RNV_SERVER_PORT`**: The port on which the server listens for webhooks and api requests. Defaults to 8080.

**`MEND_RNV_ADMIN_API_ENABLED`**: Set to 'true' to enable Admin APIs. Defaults to 'false'.

**`MEND_RNV_SERVER_API_SECRET`**: Required if Admin APIs are enabled, or if running Enterprise Edition.

**`MEND_RNV_WEBHOOK_SECRET`**: Must match the secret sent by the GitHub webhooks. Defaults to 'renovate'.

**`MEND_RNV_ENDPOINT`**: [GitHub Enterprise Server only] This is the API endpoint for your GitHub Enterprise installation. Include the trailing slash.

**`GITHUB_COM_TOKEN`**: [GitHub Enterprise Server only] A Personal Access Token for a user account on github.com (note: _not_ an account on your GitHub Enterprise instance).

**Additional Configuration options**

For further details and a list of all available options, see the [Configuration Options](configuration-options.md) page.

### Renovate CLI Configuration

Renovate CLI functionality can be configured using environment variables (e.g. `RENOVATE_XXXXXX`) or via a `config.js` file mounted to `/usr/src/app/config.js` inside the Mend Renovate container.

**npm Registry**

If using your own npm registry, you may find it easiest to update your Docker Compose file to include a volume that maps an `.npmrc` file to `/home/ubuntu/.npmrc`. The RC file should contain `registry=...` with the registry URL your company uses internally. This will allow Renovate to find shared configs and other internally published packages.
