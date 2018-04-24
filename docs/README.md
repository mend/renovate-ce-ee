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

Renovate OSS feature releases (i.e. minor version bumps in Renovate OSS) will be incorporated only into minor releases of Renovate Pro. 
i.e. patch releases of Renovate Pro will never incorporate minor releases of Renovate OSS, unless in exceptional circumstances. 
Important bug fixes in Renovate OSS will therefore be backported to whatever is the current Renovate OSS minor version in the latest Renovate Pro image, if it is not appropriate to release a new stable Renovate Pro version at that time.

## Releasing and Upgrading

The release cadence of Renovate Pro is not fixed, as it will be determined largely by the perceived stability of new Renovate OSS features, which will typically be tested using the hosted Renovate GitHub App first.
When a new version of Renovate Pro is pushed to Docker Hub, Release Notes will be added to this [github.com/renovatebot/pro](https://github.com/renovatebot/pro) repository.

We do not intend to ever "push over the top" of a semver tag on Docker Hub, e.g. the image behind tag `v1.2.0` should never change, unless in extraordinary circumstances such as backporting of a serious security bug.

Meanwhile, we may publish unversioned "latest" images to Docker Hub between releases, e.g. incorporating bleeding edge updates of Renovate Pro features and/or Renovate OSS.
It is not recommended that you adopt "latest" as your source tag for Renovate Pro, but there may be times when you wish to test a new Renovate OSS feature and that is the recommended option.

Naturally, it is recommended that you use Renovate itself for detecting and updating Renovate Pro versions if you are using a Docker Compose file internally for running Renovate Pro.

