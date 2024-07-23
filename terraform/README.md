# AWS Infrastructure for Broken Flask App

This setup will deploy the application to AWS to demonstrate that the vulnerabilities cannot be found with CNAPP/CSPM tools like Wiz, Palo Alto Prisma Cloud, or Prowler.

## Compromises made for demo purposes

The application is a simple Flask application that uses a SQLite database. It runs in a docker container on a single EC2 instance for simplicity, and so it's easier for others to understand by reading the Terraform.

It also does not use Terraform remote state because it's a simple demo. In a real-world scenario, you would use remote state - but then again, this is not a real-world app.

## Prerequisites

Create a `terraform.tfvars` file. You can copy the `terraform.tfvars.example` file and modify it to your needs.

```bash
cp terraform.tfvars.example terraform.tfvars
``` 

* The default region is `us-east-1`. You can change it in the `terraform.tfvars` file.

```terraform
domain_name = "example.com"
name        = "broken-flask"
region      = "us-east-1"
```

> [!WARNING]
> You must have a Route53 hosted zone that matches the `domain_name` in the `terraform.tfvars`. The hosted zone must be in the same AWS account where you are deploying the infrastructure, and should be created before running the Terraform. The nameservers for the hosted zone must be set up in your domain registrar. I suggest using AWS Route53 for the domain registrar and a throwaway experimental domain.
