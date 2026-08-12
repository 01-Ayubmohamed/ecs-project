# Self-Hosted Gatus Monitoring on AWS ECS Fargate

## Overview

This project is a self-hosted Gatus monitoring app, containerised and running on AWS ECS Fargate. It's provisioned through Terraform, deployed via GitHub Actions, authenticated to AWS through OIDC, and reachable on its own custom domain through Route 53.

## Architecture

![Architecture Diagram](Images/gatus-architecture.png)

## Live Demo

## Design Features

* **Two Stage Terraform Split:** Terraform is split into `bootstrap/` (state bucket, ECR, OIDC provider, IAM roles) and `infra/` (VPC, ALB, ECS) to resolve a real ordering problem. The roles a pipeline needs in order to authenticate can't be created by that same pipeline. `bootstrap/` is applied once, manually; everything in `infra/` then runs through CI/CD.

* **CI/CD Authentication:** Every pipeline (build, deploy, terraform) authenticates to AWS via GitHub OIDC, each assuming a dedicated IAM role scoped to exactly what it needs, following Role-Based Access Control (RBAC) principles. No static AWS credentials exist anywhere in the repository.

* **Immutable, Traceable Images:** ECR images are tagged by commit SHA and cannot be overwritten once pushed, so any running image traces back to the exact commit that built it. No mutable `latest` tag to lose that history.

* **Minimal Docker Attack Surface:** The final image builds `FROM scratch` and runs as a non root user, containing only the necessary components. There's no shell, no package manager, nothing for an attacker to exploit even with code execution.

* **High Availability, Secure Routing:** The ECS service runs across two Availability Zones behind an Application Load Balancer, with HTTP forced to HTTPS via a certificate managed by ACM and validated through Route 53. Security groups are scoped tightly in both directions: only the ALB can reach the tasks, and the tasks reach out only on the ports they need.

## Project Layout

```
.
├── .github/
│   └── workflows/
│       ├── build.yml
│       ├── deploy.yml
│       ├── terraform.yml
│       └── terraform.destroy.yml
├── Images/
│   └── gatus-architecture.png
├── app/
├── bootstrap/
│   ├── main.tf
│   ├── provider.tf
│   ├── variable.tf
│   ├── output.tf
│   ├── terraform.tfvars
│   └── modules/
│       ├── s3/
│       ├── ecr/
│       └── iam/
├── config/
│   └── config.yaml
├── infra/
│   ├── main.tf
│   ├── provider.tf
│   ├── variable.tf
│   ├── output.tf
│   ├── terraform.tfvars
│   └── modules/
│       ├── vpc/
│       ├── acm/
│       ├── alb/
│       ├── ecs/
│       └── iam/
├── .dockerignore
├── .gitignore
├── Dockerfile
└── README.md
```

## Security

* **OIDC Over Static Credentials:** Every pipeline authenticates to AWS through GitHub's OIDC provider instead of long lived access keys. Each pipeline role is scoped to only the permissions it needs.

* **Scanned Before It Ships:** Every image is scanned for vulnerabilities with Grype during build, and every Terraform change is scanned with Checkov before it can be applied.

* **Encryption at Rest:** The Terraform state bucket and the ECR repository are both encrypted with KMS, using AWS managed keys.

* **TLS Enforced at the Load Balancer:** The ALB uses a modern TLS policy and drops malformed HTTP headers, while HTTP traffic is forced to redirect to HTTPS.

* **Locked Down VPC:** The default VPC security group is stripped of all rules, public subnets don't automatically assign public IPs, and both the ALB and ECS security groups are scoped tightly to only the traffic they actually need.

* **Branch Protection:** Changes to `main` require a pull request and passing pipeline checks before they can merge, so nothing reaches the live infrastructure without being verified first.

## Cost Optimisations

- ECS Fargate is used instead of EC2, avoiding the operational overhead of paying for idle capacity. Tasks are further split 80/20 toward Fargate Spot, trading a small amount of interruption risk for lower compute cost.

- Only one NAT gateway is provisioned instead of one per Availability Zone, cutting the ongoing hourly and data processing charges roughly in half.

- ECR, S3, and CloudWatch are all set to expire data on a schedule instead of keeping it indefinitely. ECR keeps only the 10 most recent tagged images and drops untagged ones after 14 days, S3 clears old state versions after 30 days and incomplete uploads after 7, and CloudWatch logs are retained for 7 days.

- Encryption uses AWS managed KMS keys rather than customer managed ones, avoiding the ongoing per key charge that comes with managing your own.

## Known Limitations

- ALB deletion protection is switched off (`CKV_AWS_150`). Enabling it would block the destroy pipeline from tearing the ALB down, which conflicts directly with having an on demand teardown workflow.

- The Docker image has no HEALTHCHECK instruction (`CKV_DOCKER_2`), since the final stage builds `FROM scratch` and has no shell to run one. Health is instead verified through the ALB target group's own health checks.

- The destroy workflow's confirmation input (`CKV_GHA_7`) is a deliberate safety gate requiring someone to type `yes` before anything gets destroyed, not a flaw. The real injection risk was already fixed by passing it through an environment variable.

- CloudWatch log group encryption uses the default rather than a customer managed KMS key (`CKV_AWS_158`). Unlike S3 and ECR, which have a free AWS managed key available, CloudWatch Logs would need a dedicated key and key policy for real ongoing cost.

## Prerequisites

## Deployment Implementation

## Future Improvements
