# Renovate Pro Documentation

This folder serves to document Renovate Pro specifically and not to duplicate anything that is relevant and can be found in the [Renovate OSS repository](https://github.com/renovateapp/renovate).

## Downloading

Renovate Pro is available via public Docker Hub using the namespace [renovate/pro](https://hub.docker.com/r/renovate/pro/). 
Use of the image is as described on Docker Hub, i.e. in accordance with the [Renovate User Agreement](https://renovatebot.com/user-agreement).

## Versioning

Renovate Pro uses its own semantic versioning, separate from Renovate OSS versioning. 
Additionally, it is intended that Renovate Pro will have a slower release cadence than Renovate OSS in order to provide greater stability for Enterprise use.

Specifically for Renovate Pro's use of SemVer:

**Major**: Used only for breaking changes

**Minor**: Used for feature additions and any bug fixes considered potentially unstable

**Patch**: Used only for bug fixes that are considered to be stabilising

i.e. we do not want to ever "break you" with a patch release, or have behaviour change.

Renovate OSS feature releases (i.e. minor version bumps in Renovate OSS) will therefore only be incorporated into minor releases of Renovate Pro.

## Releasing and Upgrading

The release cadence of Renovate Pro is not fixed, as it will be determined largely by the importance and stability of new Renovate OSS features, which will typically be tested using the hosted Renovate GitHub App first.
When a new version of Renovate Pro is pushed to Docker Hub, Release Notes will be added to this [github.com/renovatebot/pro](https://github.com/renovatebot/pro) repository.

Meanwhile, we may publish unversioned "latest" images to Docker Hub between releases, e.g. incorporating bleeding edge updates of Renovate Pro features and/or Renovate OSS.

It is not recommended that you adopt "latest" as your source tag for Renovate Pro, but there may be times when you wish to test a new Renovate OSS feature and that is the recommended option.

Naturally, it is recommended that you use Renovate itself for detecting and updating Renovate Pro versions if you are using a Docker Compose file internally for running Renovate Pro.

## Running Renovate Pro

Renovate Pro runs inside a single Docker container, however it requires a sibling PostgreSQL container for running the job queue.

An [example using Docker Compose](https://github.com/renovatebot/pro/blob/master/examples/docker-compose.yml) can be found in the `examples/` directory of this repository.

Notes on the database:

- Renovate Pro comes bundled with all the SQL scripts necessary to provision and populate the tables
- It is recommended that you provide backing storage for PostgreSQL in order to achieve persistence of data
- Losing the data is not really problematic though - Renovate Pro dynamically retrieves the list of installed repositories every time it is scheduled anyway
- If you wish to run the DB using a different hostname, username or password then it is your responsibility. Renovate Pro uses the [pg](https://www.npmjs.com/package/pg) library and therefore supports its environment variables for configuration

## Configuration

### GitHub Enterprise App

Before running Renovate Pro, you need to provision it as an App on GitHub Enterprise, and retrieve the ID + private key provided. This requires GitHub Enterprise 2.12 or later. It is recommended that you name the app "renovate" so that it shows up as "renovate[bot]" in Pull Requests.

### Renovate Pro

Renovate Pro requires configuration via environment variables in addition to Renovate OSS's regular configuration:

**`LICENSE_ACCEPT`**: Renovate Pro will not run unless you accept the terms of the [Renovate User Agreement](https://renovatebot.com/user-agreement) by setting this environment variable to `y`. This is required whether you are running Renovate Pro in commercial or evaluation mode.

**`LICENSE_MODE`**: If you have purchased a commercial license for Renovate Pro then you need to set this value to `commercial` to enable more than 3 repositories and remove the evaluation mode banner from PRs. Leave empty for evaluation mode.

**`LICENSE_NAME`**: To enable commercial mode, you need to also fill in the company name that the commercial license is registered to. It should match what you entered in the order form. Leave empty for evaluation mode.

**`GITHUB_ENDPOINT`**: This is the API endpoint for your GitHub Enterprise installation.

**`GITHUB_APP_ID`**: The GitHub App ID provided by GitHub Enterprise when you created the Renovate app.

**`GITHUB_APP_KEY`**: A string representation of the private key provided by GitHub Enterprise for Renovate. To insert the value directly in Docker Compose, open the PEM file in a text editor and replace new lines with "\n" so that the entire key is on one line. Alternatively, you can skip setting this key as an environment variable and instead mount it as a file to `/usr/src/app/renovate.private-key.pem` as shown in the example Docker Compose file.

**`GITHUB_COM_TOKEN`**: A Personal Access Token for a user account on github.com (i.e. *not* an account on your GitHub Enterprise instance). This is used for retrieving changelogs and release notes from repositories hosted on github.com. Also note: do not configure `GITHUB_TOKEN`.

### Renovate OSS

The core Renovate OSS functionality can be configured using environment variables or via a `config.js` file that you mount inside the Renovate Pro container to `/usr/src/webapp`.
