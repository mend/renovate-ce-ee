# Renovate Pro for GitLab

Renovate Pro is available for companies that use GitLab for development. It may be used for self-hosted GitLab instances as well as for repositories hosted on gitlab.com

## Renovate Pro features

#### Job scheduler

The Renovate Pro's Docker container contains a built-in job scheduler that defaults to enqueing all repositories once per hour. This saves the need for configuring and monitoring any external `cron` process.

#### Webhook handler

Renovate Pro also supports a webserver to listen for webhooks received from GitLab.

In particular, Renovate looks for:

  - Commits to `master` branch for "important" files such as `package.json` and `renovate.json`
  - Any commits made to Renovate's branches
  - Closing or merging of Renovate PRs
  
Each of the above results in a job being enqueued for the relevant repository, so that the bot will appear responsive to users.

#### Priority job queue

Renovate Pro uses a Postgres database to maintain a stateful and priority-based job queue.

Statefulness is important, because it means that any interruptions to the bot - including intentional such as for upgrades - will not result in the bot "starting over" at the beginnign of the list of repositories.
Instead, the job queue is kept in the database instead of the bot's memory, so once the bot is restarted it can resume where it left off.

Priority-based queuing is also essential for providing a responsive experience for bot users. For example, if a user makes an update to the config in an onboarding PR, they ideally want to see the results immediately. By assigning onboarding updates the highest priority in the queue, the bot's update to the onbaording PR can proceed as the very next job, even if many others were in the queue already.

In general, the priority is based on the probability that a user may be "waiting" for the bot to do something. That's why onboarding updates are highest priority, and other high priority updates include merging of Renovate PRs because that very often results in other PRs needing updates or rebasing afterwards.

## Renovate Pro Installation and Setup

#### Bot Account creation

You should use a dedicated "bot account" for Renovate. Apart from reducing the chance of conflicts, it is better for teams if the actions they see from Renovate are clearly marked as coming from a known bot account and not from a team mate's account, which could be confusing at times. e.g. did the bot automerge that PR, or did a human do it manually?

If you are running your own instance of GitLab, it's suggested to name the account "Renovate Bot" with username "renovate-bot". Create this account and then create a Personal Access Token for it with read/write access permissions.

#### Bot Server setup

The server setup for Renovate Pro for GitLab is essentially the same as for GitHub Enterprise, so you can look at those examples. Renovate Pro needs only a low-mid range server with Docker capabilities (e.g. 1 VCPU with 3.75GB of RAM).

## Configuration

#### Renovate Pro environment variables

Renovate Pro requires configuration via environment variables in addition to Renovate OSS's regular configuration:

**`ACCEPT_AGREEMENT`**: Renovate Pro will not run unless you accept the terms of the [Renovate User Agreement](https://renovatebot.com/user-agreement) by setting this environment variable to `y`. This is required whether you are running Renovate Pro in commercial or evaluation mode.

**`LICENSE_MODE`**: If you have purchased a commercial license for Renovate Pro then you need to set this value to `commercial` to enable more than 3 repositories and remove the evaluation mode banner from PRs. Leave this field empty to default to evaluation mode.

**`LICENSE_NAME`**: To enable commercial mode, you also need to also fill in the company name that the license is registered to. It should match what you entered in the order form. Leave empty for evaluation mode.

**`WEBHOOK_SECRET`**: This is _optional_ and will default to `renovate` if not configured.

**`SCHEDULER_CRON`**: This configuration option accepts a 5-part cron schedule and is _optional_. It defaults to `0 * * * *` (i.e. once per hour exactly on the hour) if it is not configured. If you are decreasing the interval then be careful that you do not exhaust the available hourly API rate limit of the app on GitHub Enterprise or cause too much load.

#### npm registry configuration

If using your own internal npm registry, you may find it easiest to update your Docker configuration to include a volume that maps an `.npmrc` file to `/home/node/.npmrc` inside the Renovate container. The RC file should contain `registry=...` with the registry URL your company uses internally. This will allow Renovate to find shared configs and other internally published packages.

#### Core Renovate Configuration

The "core" Renovate functionality (i.e. same functionality you'd find in the CLI version or the hosted app) can be configured using environment variables (e.g. `RENOVATE_XXXXXX`) or via a `config.js` file that you mount inside the Renovate Pro container to `/usr/src/webapp/config.js`. Here are some essentials:

**`RENOVATE_PLATFORM`**: Set this to "gitlab".

**`GITLAB_ENDPOINT`**: This is the API endpoint for your GitLab host.

**`GITLAB_TOKEN`**: A Personal Access Token for the GitLab bot account.

**`GITHUB_TOKEN`**: A Personal Access Token for any user account on github.com. This is used for retrieving changelogs and release notes from repositories hosted on github.com and it does not matter which account it belongs to. It needs only read-only access privileges to public repositories.

## Getting Started

At this point you should be ready to test out Renovate Pro for GitLab. Ideally, your bot user should not be a member of any repositories yet. That way, you can verify that the bot is running happily, but it won't need to create any PRs yet.

You may want to customise the default `cron` schedule to be more frequent during this setup period so you are not left waiting so long to see schedule logs.

## Adding repositories

By now, Renovate Pro should be ready for some real work - so it's time to test out the first repository. To do this, simply add the bot account you created to the project you want Renovate to be active on. However, there is one decision to be made - whether to set up webhooks manually or automatically. 

Renovate Bot can't provision webhooks for a repository itself unless its account has "Maintainer" [permissions](https://docs.gitlab.com/ce/user/permissions.html). If you add Renovate Bot with "Developer" permissions then you will need to manually configure webhooks for each repository. Therefore it's recommended to (a) add Renovate Bot initially at Maintainer level for at least one hour, and then (b) downgrade it to Developer level once it's run at least once.
