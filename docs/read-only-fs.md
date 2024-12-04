# Read-only File Systems

Support for read-only file systems is available from version 9.0.0

To test it, follow these steps:

## Use pre-release EE images

The official release images:
* Community: `ghcr.io/mend/renovate-ce:9.0.0`
* Enterprise: `ghcr.io/mend/renovate-ee-server:9.0.0` and `ghcr.io/mend/renovate-ee-worker:9.0.0`

## Run the images in read-only mode

Set both the Server and Worker images to run with read-only file systems (e.g. `readOnlyRootFilesystem` in Kubernetes).

## Map read-write volumes

Ensure that the EE Server has a read-write `/tmp` volume.

Ensure that the EE Worker has read-write `/tmp` and `/opt/containerbase` volumes.

## Other volumes

The main "risk" of a read-only FS for Renovate is that there are dozens of package managers that can be called, and those package managers can choose to write files into unexpected locations.

When such cases are found, the best scenario is that the Renovate CLI can be enhanced to "coerce" managers into writing to `/tmp/renovate`, e.g. through the configuration of environment variables.
However, it may also be feasible to selectively map files or folders as a stopgap solution (e.g. `/home/ubuntu/.some-manager`).

## Testing and release

The measure of success is that all packager managers succeed (e.g. at updating lock files) using the read-write volumes only.
