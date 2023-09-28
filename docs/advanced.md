# Mend Renovate Advanced Details

## Modules

### In-memory Database

This database is used to keep track of installed repositories as well as the job queue.
Naturally, it is cleared upon container restart and repopulated upon container start.

### Scheduler

For GitHub, the scheduler:

- Queries the GitHub server for a list of organization or account App installations
- Obtains a list of all installed repositories for each installation
- Randomizes the list and adds them all to the database's job queue

For GitLab, the scheduler:

- Queries the GitLab server for a list of repositories that the bot account has Developer or greater access rights to
- Randomizes the list and adds them all to the database's job queue

It runs according to its configured `cron` schedule, which defaults to running on the hour.

### Webhook Handler

The webhook handler listens for events from the VCS server and adds or updates jobs in the job queue if the criteria are met.

An example criterion is if someone edits the `renovate.json` in `main` branch - this would trigger a high priority job.

To ensure that one repository doesn't get queued up multiple times, the database enforces a rule that each repository can be queued at most once at a time.
Therefore if the repository already exists in the job queue (e.g. due to the hourly scheduler) and then a higher priority job reason comes up, then the existing entry in the job queue will have its priority updated in order to get processed earlier.

### Worker

The worker runs on an endless loop where it queries the DB for the next job (sorted by priority) and processes whatever repository it is given.
If the job queue is empty, it sleeps for a second before retrying.

If the Mend Renovate server receives a SIGINT (e.g. maybe you are upgrading it and want to restart it with a newer image), then the worker will attempt to finish whatever job it is currently processing before shutting down gracefully.
Therefore it is recommended to supply a long timeout value (e.g. 60+ seconds) to Docker in order to allow the worker to finish what it's working on.

Here is an except showing the relative priority of job types:

```
  ('onboarding-update', 20),
  ('pr-update', 30),
  ('closed-pr-rename', 35),
  ('manual-pr-merge', 40),
  ('repositories-added', 50),
  ('installed', 60),
  ('master-commit', 70),
  ('automerge', 80),
  ('manual-pr-close', 90),
  ('scheduled', 100);
```

Note: For consistency, the abbreviation `pr` is used in the job queue for both GitHub and GitLab, even though GitLab uses the term "Merge Request" instead of "Pull Request".

In other words, the highest priority job is when someone commits an update to the config in an onboarding PR, and the lowest priority jobs are the ones added by the scheduler.
The above job types have been sorted in order of how quickly users would expect to receive feedback.
Because onboarding is an interactive process, it needs the most responsiveness.

## Horizontal Scaling

The current architecture of Mend Renovate is monolithic in order to keep things simple and maximize maintainability.
Accordingly, there is a 1:1 relationship between the worker and the job queue, meaning that only one job can be processed at a time.
