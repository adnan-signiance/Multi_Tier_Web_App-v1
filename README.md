# Multi-Tier Web App on AWS

A production-ready, 3-tier web application deployed on AWS using **Terraform** with a fully automated **CI/CD pipeline** using CodePipeline, CodeBuild, and CodeDeploy (Blue-Green ECS deployment).

---

## 🏗️ Architecture Overview

```
Internet
   │
   ▼
CloudFront (CDN)
   │
   ▼
ALB (Application Load Balancer)
   │
   ├── Blue Target Group ──┐
   └── Green Target Group ─┤── ECS Cluster (EC2)
                           │      ├── client container  (React/Nginx  :80)
                           │      └── server container  (Node.js      :5000)
                           │
                          RDS MySQL (private subnet)
                           │
                     Secrets Manager (credentials)
```

| Layer | Technology |
|---|---|
| **Frontend** | React (Vite) + Nginx |
| **Backend** | Node.js + Express |
| **Database** | MySQL on AWS RDS |
| **Container Orchestration** | AWS ECS (EC2 launch type) |
| **CDN** | AWS CloudFront |
| **Load Balancer** | AWS ALB (blue/green target groups) |
| **Infrastructure** | Terraform (modular) |
| **CI/CD** | CodePipeline + CodeBuild + CodeDeploy |
| **Secrets** | AWS Secrets Manager |
| **Monitoring** | CloudWatch + SNS |

---

## 📁 Project Structure

```
.
├── app/
│   ├── client/          # React frontend (Vite + Nginx)
│   ├── server/          # Node.js backend (Express + MySQL)
│   └── docker-compose.yml
├── terraform/
│   ├── main.tf          # Root module — wires all modules together
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf       # S3 remote state
│   ├── terraform.tfvars
│   └── modules/
│       ├── vpc/         # VPC, subnets, SGs, NAT Gateway
│       ├── alb/         # ALB, blue/green target groups, listener
│       ├── ecs/         # ECS cluster, task definition, service, ECR repos
│       ├── rds/         # RDS MySQL instance
│       ├── iam/         # All IAM roles and policies
│       ├── s3/          # CodePipeline artifact bucket
│       ├── cicd/        # CodePipeline, CodeBuild, CodeDeploy
│       ├── secretsmanager/ # DB credentials secret
│       ├── cloudfront/  # CloudFront distribution
│       ├── sns/         # Alerting topic
│       └── cloudwatch/  # Alarms and dashboards
├── appspec.yaml         # CodeDeploy ECS blue-green instruction file
├── taskdef.json         # ECS task definition template (placeholders)
├── buildspec.yml        # CodeBuild build instructions
└── README.md
```

---

## 🚀 CI/CD Pipeline

Every push to `main` triggers an automated pipeline:

```
git push origin main
      │
      ▼
┌─────────────┐    ┌─────────────┐    ┌──────────────────────┐
│   SOURCE    │───▶│    BUILD    │───▶│       DEPLOY         │
│  (GitHub)   │    │ (CodeBuild) │    │  (CodeDeployToECS)   │
└─────────────┘    └─────────────┘    └──────────────────────┘
  Detects push      Builds Docker      Blue-Green traffic shift
  to main via       images, pushes     via ALB — zero downtime
  CodeStar          to ECR, renders    Auto-rollback on failure
  Connection        taskdef.json
```

### Key Files

| File | Role |
|---|---|
| `buildspec.yml` | Tells CodeBuild how to build images, what to output |
| `appspec.yaml` | Tells CodeDeploy which ECS service/container/port to update |
| `taskdef.json` | ECS task definition template — placeholders replaced at build time |

### Blue-Green Deployment Flow

1. CodeBuild pushes new Docker images to ECR
2. CodePipeline registers a new ECS task definition revision from `taskdef.json`
3. CodeDeploy starts new tasks (Green) alongside old tasks (Blue)
4. Health checks pass on Green → ALB shifts 100% traffic Blue → Green
5. Old Blue tasks terminated after 5-minute safety window
6. Auto-rollback triggered if deployment fails

---

## 🛠️ Local Development

### Prerequisites

- Docker & Docker Compose
- Node.js 18+
- MySQL (or use Docker)

### Run with Docker Compose

```bash
cd app
docker-compose up --build
```

| Service | URL |
|---|---|
| Frontend | http://localhost |
| Backend API | http://localhost:5000 |
| Database | localhost:3306 |

### Run Manually

```bash
# Database
mysql -u root -p < app/server/schema.sql

# Backend
cd app/server && cp .env.example .env
npm install && npm run dev

# Frontend
cd app/client && cp .env.example .env
npm install && npm run dev
```

---

## ☁️ AWS Deployment (Terraform)

### Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.0
- An S3 bucket for Terraform state (`bkt-terraform-adnan`)

### Deploy

```bash
cd terraform

# 1. Set your variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — set region, db_username, db_password

# 2. Initialize (downloads providers + modules)
terraform init

# 3. Preview changes
terraform plan

# 4. Deploy everything
terraform apply
```

### Outputs after `terraform apply`

```
alb_dns_name                 = "alb-adnan-xxx.us-east-1.elb.amazonaws.com"
cloudfront_domain_name       = "xxx.cloudfront.net"
frontend_ecr_repository_url  = "841162706975.dkr.ecr.us-east-1.amazonaws.com/frontend"
backend_ecr_repository_url   = "841162706975.dkr.ecr.us-east-1.amazonaws.com/backend"
rds_endpoint                 = "xxx.rds.amazonaws.com:3306"
sns_topic_arn                = "arn:aws:sns:us-east-1:..."
vpc_id                       = "vpc-xxx"
```

### ⚠️ One-Time Manual Step — Authorize GitHub Connection

After first `terraform apply`, the CodeStar GitHub connection needs to be authorized:

1. Go to **AWS Console → CodePipeline → Settings → Connections**
2. Find `github-ecs-connection` (Status: **Pending**)
3. Click **Update pending connection** → Authorize with your GitHub account

---

## 🔐 Security

| Concern | Solution |
|---|---|
| Database credentials | AWS Secrets Manager (never in code) |
| Private networking | RDS in private subnets, no public access |
| Least privilege IAM | Separate roles for ECS, CodeBuild, CodeDeploy, CodePipeline |
| Container secrets | ECS native secrets injection from Secrets Manager |
| Traffic | ALB + CloudFront, ECS not directly exposed |

---

## 📊 Monitoring

- **CloudWatch Alarms**: ECS memory utilization, ALB request count, ALB response time
- **SNS Alerts**: Email notifications on alarm state change (`ec2-updates-topic`)
- **CloudWatch Logs**: Container logs at `/ecs/app-task/server` and `/ecs/app-task/client`

---

## ✅ Best Practices

- ✅ No hardcoded secrets — all via Secrets Manager and Terraform variables
- ✅ Remote Terraform state in S3
- ✅ Modular Terraform architecture (11 modules)
- ✅ Zero-downtime deployments via ECS blue-green + CodeDeploy
- ✅ Auto-rollback on deployment failure
- ✅ Docker layer caching in CodeBuild (LOCAL_DOCKER_LAYER_CACHE)
- ✅ Separate IAM roles with least-privilege policies
- ✅ Private RDS with security group restrictions
- ✅ CloudFront + ALB for scalable, cached content delivery
