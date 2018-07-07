# Setting up AWS for Renovate Pro using Terraform

## Introduction

This README/directory provides an example Terraform setup for Renovate Pro on AWS. It is intended to be generic and reusable, however there may be some fields or settings that are not required for everyone. Please contribute back via a Pull Request if you think anything should be added or deleted by default for most users.

## Prequisites

You will need to make sure you have [Terraform](https://www.terraform.io/downloads.html) installed, as well as [AWS CLI](https://aws.amazon.com/cli/).

## Steps

1. Clone this repo or copy this subdirectory manually
2. Run `terraform init`
3. Fill in the necessary values in the `terraform.tfvars` file
4. Login to AWS CLI so that a credentials file is generated to `~/.aws/credentials`
5. Run `terraform plan` to see an overview of the rollout
6. Run `terraform apply` when ready to deploy
7. SSH into your new EC2 instance and create the `docker-compose.yml` as well as the PEM file required from GitHub. (this will be automated eventually, PRs welcome!)
8. Run `docker-compose up -d` to start the server.
