# Self Hosted Gatus Monitoring on AWS ECS Fargate

## Overview

## Architecture

## Live Demo


## Design Features

## Project Layout

```
.
├── .github/
│   └── workflows/
│       ├── build.yml
│       ├── deploy.yml
│       ├── terraform.yml
│       └── terraform.destroy.yml
├── app/
├── bootstrap/
│   ├── main.tf
│   ├── provider.tf
│   ├── variable.tf
│   ├── output.tf
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

## Cost Optimisations

## Prerequisites

## Known Limitations

## Deployment Implementation

## Future Improvements
