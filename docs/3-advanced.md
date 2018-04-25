# Renovate Pro Advanced Details

## Database

In short, the database should be considered as just a component of Renovate and not something you need to manually read or write to.

#### Provisioning and Migration

The Renovate Pro docker image comes with SQL migration scripts that are used for provisioning and migrating the database between schema versions. 
If the schema version has changed between two Renovate Pro releases, then the first thing that Renovate Pro will do after restart is to migrate the existing tables and data to the new schema, before starting the scheduler, worker and webhook listener.

This same migration approach also includes the capability to *roll back* schema changes, e.g. if you upgraded Renovate Pro but found a problem requiring you to roll back.
The only caveat to this is that you may need to pull the latest image of your "old" version from Docker Hub in order to make sure it is populated with the latest roll back scripts (migration scripts are backported to older versions for this purpose).

#### Persistence, backup and restore

Just like Renovate OSS at its core, Renovate Pro remains as "stateless" as possible and is ideally immune to many common database problems like lost data.

If all data were lost, the impact is fairly limited:

1. The job queue would be lost, however it would be repopulated the very next time the scheduler runs.
2. The job history table would be lost, however the usefulness of its data is fairly limited anyway.
3. The list of installations and repositories would be lost, however they would be repopulated the next time the scheduler runs and the worker completes one cycle.

Hence, whether you choose to implement backup and restore policies depends on how much you value the historical job history vs whether you are willing to have Renovate "downtime" while you manually restore the database.

#### Custom database

Each of Renovate Pro's modules that interact with the database use the [pg](https://www.npmjs.com/package/pg) library. Therefore if you wish to use your own Postgresql database, it should be possible in most cases by specifying the same [environment variables](https://www.postgresql.org/docs/9.1/static/libpq-envars.html) as in libpq, e.g. `PGHOST`, `PGUSER`, etc. You however cannot customise the tables names that Renovate creates and uses.

Please note that Renovate Pro has only been tested with PostgreSQL 10.x. 

## Scheduler

The scheduler is a Renovate Pro module that:

- Queries GitHub Enterprise for a list of all installed accounts
- Obtains a list of all installed repositories for each account
- Randomizes the list and adds them all to the database's job queue

It runs according to its configured `cron` schedule.

## Webhook Handler

The webhook handler listens for events from GitHub and adds or updates jobs in the job queue if the criteria are met.

An example criteria is if someone edits the `renovate.json` in `master` branch - this would trigger a high priority job.

To ensure that one repository doesn't get queued up multiple times, the database enforces a rule that each repository can be queued at most once at a time.
Therefore if the repository already exists in the job queue (e.g. due to the hourly scheduler) and then a higher priority job reason comes up, then the existing entry in the job queue will have its priority updated in order to get processed earlier.

## Worker

The worker runs on an endless loop where it queries the DB for the next job (sorted by priority) and processes whatever repository it is given. If the job queue is empty, it sleeps for a second before retrying.

If the Renovate Pro server receives a SIGINT (e.g. maybe you are upgrading Renovate Pro and want to restart it with a newer image), then the worker will attempt to finish whatever job it is currently processing before shutting down gracefully.
Therefore it is recommended to supply an ample timout value (e.g. 60+ seconds) to Docker in order to allow the worker to finish what it's working on.
That way it can resume with the next job in the queue after its restart.

Here is an except showing the relative priority of job types:
```
  ('onboarding-update', 20),
  ('pr-update', 30),
  ('manual-pr-merge', 40),
  ('repositories-added', 50),
  ('installed', 60),
  ('master-commit', 70),
  ('automerge', 80),
  ('manual-pr-close', 90),
  ('scheduled', 100);
  ```
  
In other words, the highest priority job is when someone commits an update to the config in an onboarding PR, and the lowest priority jobs are the ones added by the scheduler. The above job types have been sorted in order of how quickly users would expect to receive feedback. Because onboarding is an interactive process, it needs the most responsiveness.
