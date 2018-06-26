![Renovate banner](https://renovatebot.com/images/design/header_small.jpg)

# Renovate Pro Edition

This repository contains Documentation, Release Notes and an Issue Tracker for the Renovate "Pro Edition" container.

## Getting Started

Before starting, you will need to make sure you have [Terraform](https://www.terraform.io/downloads.html) installed, as well as [AWS CLI](https://aws.amazon.com/cli/)

1. Clone the repo
2. Run `terraform init`
3. Fill in the necessary values in the `terraform.tfvars` file
4. Login to AWS CLI so that a credentials file is generated to `~/.aws/credentials`
5. Run `terraform plan` to see an overview of the rollout
6. Run `terraform apply` when ready to deploy
7. SSH into your new EC2 instance and create the `docker-compose.yml` as well as the PEM file required from GitHub. (this will be automated eventually, PRs welcome!)
8. Run `sudo docker-compose up -d` to start the server.

## License

Renovate Pro is commercial software, and bound by the terms of the Renovate User Agreement.

The documentation and examples in this repository are MIT-licensed.

## Download

Renovate Pro is distributed via Docker Hub using the [renovate/pro](https://hub.docker.com/r/renovate/pro/) namespace.

## Use

Please see the `docs/` and `examples/` directories within this repository.
