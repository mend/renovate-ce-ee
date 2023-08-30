# Mend Renovate Configuration for GitLab

Mend Renovate is available for teams that use GitLab for development.
It may be used for self-hosted GitLab instances as well as for repositories hosted on gitlab.com

## Mend Renovate features

#### Job scheduler

The Mend Renovate's Docker container contains a built-in job scheduler that defaults to enqueing all repositories once per hour.
This saves the need for configuring and monitoring any external `cron` process.

#### Webhook handler

Mend Renovate also supports a webserver to listen for system webhooks received from GitLab.

In particular, Renovate checks webhooks for:

- Projects it has just been added to
- Commits to `master` branch for "important" files such as `package.json` and `renovate.json`
- Any commits made to Renovate's branches
- Closing or merging of Renovate PRs

Each of the above results in a job being enqueued for the relevant repository, so that the bot will appear responsive to users.

#### Priority job queue

Priority-based queuing is essential for providing a responsive experience for bot users.
For example, if a user makes an update to the config in an onboarding PR, they ideally want to see the results immediately.
By assigning onboarding updates the highest priority in the queue, the bot's update to the onboarding PR can proceed as the very next job, even if many others were in the queue already.

In general, job priority is based on the probability that a user may be "waiting" for the bot to do something.
That's why onboarding updates are highest priority, and other high priority updates include merging of Renovate PRs because that very often results in other PRs needing updates or rebasing afterwards.

## Mend Renovate Installation and Setup

#### Bot Account creation

You should use a dedicated "bot account" for Renovate.
Apart from reducing the chance of conflicts, it is better for teams if the actions they see from Renovate are clearly marked as coming from a dedicated bot account and not from a teammate's account, which could be confusing at times.
e.g. did the bot automerge that PR, or did a human do it?

If you are running your own instance of GitLab, it's suggested to name the account "Renovate Bot" with username "renovate-bot".
Create this account and then create a Personal Access Token for it with `api`, `read_user` and `write_repository` permissions.

It's best not add this bot account to any repositories yet.

#### Bot Server setup

The server setup for Mend Renovate for GitLab is essentially the same as for GitHub Enterprise, so you can look at those examples.
Mend Renovate needs only a low-mid range server with Docker capabilities (e.g. 1 VCPU with 3.75GB of RAM).

## Configuration

#### Mend Renovate environment variables

Mend Renovate requires configuration via environment variables in addition to Renovate OSS's regular configuration:

**`ACCEPT_WHITESOURCE_TOS`**: Set this environment variable to `y` to consent to [Mend Renovate's Terms of Service](https://renovate.whitesourcesoftware.com/terms-of-service/).

**`LICENSE_KEY`**: This should be the license key you obtained after registering at [https://renovate.whitesourcesoftware.com/on-premises/](https://renovate.whitesourcesoftware.com/on-premises/).

**`WEBHOOK_SECRET`**: This is _optional_ and will default to `renovate` if not configured.

**`SCHEDULER_CRON`**: This configuration option accepts a 5-part cron schedule and is _optional_. It defaults to `0 * * * *` (i.e. once per hour exactly on the hour) if it is not configured. If you are decreasing the interval then be careful that you do not exhaust the available hourly API rate limit or cause too much load.

#### Core Renovate Configuration

"Core" Renovate functionality (i.e. same functionality you'd find in the CLI version or the hosted app) can be configured using environment variables (e.g. `RENOVATE_XXXXXX`) or via a `config.js` file that you mount inside the Mend Renovate container to `/usr/src/app/config.js`.
Here are some essentials for Mend Renovate:

**`RENOVATE_PLATFORM`**: Set this to `gitlab`.

**`RENOVATE_ENDPOINT`**: This is the API endpoint for your GitLab host. e.g. like `https://gitlab.company.com/api/v4/`

**`RENOVATE_TOKEN`**: A Personal Access Token for the GitLab bot account.

**`GITHUB_COM_TOKEN`**: A Personal Access Token for a valid user account on github.com. This is only used for retrieving changelogs and release notes from repositories hosted on github.com so it does not matter which account it belongs to. It needs only read-only access privileges to public repositories.

#### System Hook

To activate Mend Renovate's webhook ability, a GitLab administrator needs to configure a System Hook that points to the Renovate installation.

Configure it to point to Mend Renovate's server, e.g. `http://renovate.company.com:8080/webhook` or `https://1.2.3.4/webhook`.

Remember: Renovate's webhook listener binds to port 8080 inside its container, but you can map it (using Docker) to whatever external port you require, including port 80.

Set the "Secret Token" to the same value you configured for `WEBHOOK_SECRET` earlier, or set it to `"renovate"` if you left it as default.

Set Hook triggers for "Push events", "Merge request events" and "Issue events".

Once you a System Hook is added, Renovate's webhook handler will receive events from _all_ repositories.
Therefore, Renovate maintains a list of all repositories it has access to and discards events from all others.

## Testing Mend Renovate

At this point you should be ready to test out Mend Renovate.
You probably want to create a test repo before adding Mend Renovate to any "real" ones.
To simulate normal conditions, create the repository from a regular account and add a package file.

#### Enabling Renovate

To enable Renovate on your test repository, simply add the bot user you created to the project with "Developer" permissions.

Adding Renovate as a Developer to a repository cause a system hook to be sent to Renovate which in turn enqueues a job for the Renovate Worker.
The repository should receive an onboarding PR immediately after.
