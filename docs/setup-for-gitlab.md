# Set up Mend Renovate Self-hosted for GitLab

## Configure Renovate Bot Account on GitLab

### Renovate Bot Account

Create a GitLab user account to act as the "Renovate Bot".
If you are running your own instance of GitLab, it's suggested to name the account "Renovate Bot" with username "renovate-bot".

Note: In GitLab, the "Renovate Bot" is not an App or Plugin; it's a GitLab user account that's been given the right permissions and System Hooks.
You should use a dedicated "bot account" for Renovate, instead of using someone's personal user account.
Apart from reducing the chance of conflicts, it is better for teams if the actions they see from Renovate are clearly marked as coming from a dedicated bot account and not from a teammate's account, which could be confusing at times.
e.g. Did the bot automerge that PR, or did a human do it?

### Personal Access Token

Once the account is created, create a Personal Access Token for it with the following permissions:
  * `api`
  * `read_user`
  * `write_repository`

### System Hook

To activate Mend Renovate's webhook ability, create a System Hook that points to the Renovate installation.

Create a System Hook (in Admin area)

1. Set the webhook URL to point to the Renovate server url followed by `/webhook`. (e.g. `http://renovate.yourcompany.com:8080/webhook` or `https://1.2.3.4/webhook`)
2. Set the webhook secret to the same value configured for `MEND_RNV_WEBHOOK_SECRET` (defaults to `renovate`)
3. Set Hook triggers for:
   * `Push events`
   * `Merge request events`

Remember: Renovate's webhook listener binds to port 8080 inside its container, but you can map it (using Docker) to whatever external port you require, including port 80.

Set the "Secret Token" to the same value configured for `MEND_RNV_WEBHOOK_SECRET`, or set it to `"renovate"` if you left it as default.

Once your System Hook is added, Renovate's webhook handler will receive events from _all_ repositories.
Therefore, Renovate maintains a list of all repositories it has access to and discards events from all others.

### Repo Webhooks

Because Issue events aren't included in System hooks, a webhook must be individually configured for each repository in which you want the Dependency Dashboard issue to be interactive.

In the Repository settings, create a Webhook with the following settings:
1. Set the webhook URL - same as System Hook URL
2. Set the webhook secret - same as System Hook secret
3. Set Hook triggers for:
    * `Issue events`

This will need to be repeated for every repository that is onboarded to the Renovate Bot account.
It is usually easiest to create the repo webhook while adding the Renovate Bot account to a repo.

## Run Mend Renovate Self-hosted

You can run Mend Renovate Self-hosted from a Docker command line prompt, or by using a Docker Compose file. Examples are provided in the links below.

**Example Docker Compose files:**

- [Mend Renovate Community Edition](../examples/docker-compose/renovate-ce.yml)
- [Mend Renovate Enterprise Edition](../examples/docker-compose/renovate-ee.yml)

> [!NOTE]
>
> Some configuration of environment variables will be required inside the Docker Compose files.
>
> Essential configuration options are shown below. For a full list of configurable variables, see [Configuration Options](configuration-options.md).

## Configure Environment Variables

### Essential Configuration for Mend Renovate Sever

**`MEND_RNV_ACCEPT_TOS`**: Set this environment variable to `y` to consent to [Mend's Terms of Service](https://www.mend.io/terms-of-service/).

**`MEND_RNV_LICENSE_KEY`**: Register for a free Community Edition license key at https://www.mend.io/renovate-community/. For an Enterprise License key, contact Mend at http://mend.io.

**`MEND_RNV_PLATFORM`**: Set this to `gitlab`.

**`MEND_RNV_ENDPOINT`**: This is the API endpoint for your GitLab host. e.g. like `https://gitlab.company.com/api/v4/`. Include the trailing slash.

**`MEND_RNV_SERVER_PORT`**: The port on which the server listens for webhooks and api requests. Defaults to 8080.

**`MEND_RNV_GITLAB_PAT`**: Personal Access Token for the GitLab bot account.

**`MEND_RNV_ADMIN_API_ENABLED`**: Set to 'true' to enable Admin APIs. Defaults to 'false'.

**`MEND_RNV_SERVER_API_SECRET`**: Required if Admin APIs are enabled, or if running Enterprise Edition.

**`MEND_RNV_WEBHOOK_SECRET`**: Must match the secret sent by the GitHub webhooks. Defaults to 'renovate'.

**`GITHUB_COM_TOKEN`**: A Personal Access Token for a user account on github.com

**Additional Configuration options**

For further details and a list of all available options, see the [Configuration Options](configuration-options.md) page.

### Renovate CLI Configuration

Renovate CLI functionality can be configured using environment variables (e.g. `RENOVATE_XXXXXX`) or via a `config.js` file mounted to `/usr/src/app/config.js` inside the Mend Renovate container.

**npm Registry**

If using your own npm registry, you may find it easiest to update your Docker Compose file to include a volume that maps an `.npmrc` file to `/home/ubuntu/.npmrc`. The RC file should contain `registry=...` with the registry URL your company uses internally. This will allow Renovate to find shared configs and other internally published packages.
