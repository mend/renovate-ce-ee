# Renovate Pro Configuration

## GitHub Enterprise App

Before running Renovate Pro, you need to provision it as an App on GitHub Enterprise, and retrieve the ID + private key provided. This requires GitHub Enterprise 2.12 or later. It is recommended that you name the app "renovate" so that it shows up as "renovate[bot]" in Pull Requests.

## Renovate Pro

Renovate Pro requires configuration via environment variables in addition to Renovate OSS's regular configuration:

**`LICENSE_ACCEPT`**: Renovate Pro will not run unless you accept the terms of the [Renovate User Agreement](https://renovatebot.com/user-agreement) by setting this environment variable to `y`. This is required whether you are running Renovate Pro in commercial or evaluation mode.

**`LICENSE_MODE`**: If you have purchased a commercial license for Renovate Pro then you need to set this value to `commercial` to enable more than 3 repositories and remove the evaluation mode banner from PRs. Leave empty for evaluation mode.

**`LICENSE_NAME`**: To enable commercial mode, you need to also fill in the company name that the commercial license is registered to. It should match what you entered in the order form. Leave empty for evaluation mode.

**`GITHUB_ENDPOINT`**: This is the API endpoint for your GitHub Enterprise installation.

**`GITHUB_APP_ID`**: The GitHub App ID provided by GitHub Enterprise when you created the Renovate app.

**`GITHUB_APP_KEY`**: A string representation of the private key provided by GitHub Enterprise for Renovate. To insert the value directly in Docker Compose, open the PEM file in a text editor and replace new lines with "\n" so that the entire key is on one line. Alternatively, you can skip setting this key as an environment variable and instead mount it as a file to `/usr/src/app/renovate.private-key.pem` as shown in the example Docker Compose file.

**`GITHUB_COM_TOKEN`**: A Personal Access Token for a user account on github.com (i.e. *not* an account on your GitHub Enterprise instance). This is used for retrieving changelogs and release notes from repositories hosted on github.com. Also note: do not configure `GITHUB_TOKEN`.

## Renovate OSS

The core Renovate OSS functionality can be configured using environment variables or via a `config.js` file that you mount inside the Renovate Pro container to `/usr/src/webapp`.
