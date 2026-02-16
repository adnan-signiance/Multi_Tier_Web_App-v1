# 📁 Quick File Reference Guide

## Terraform Files (Infrastructure)

### Root Level (`terraform/`)
```
main.tf              → Orchestrates all modules ⭐
variables.tf         → Input variables (region, AMI)
locals.tf            → Common tags
backend.tf           → S3 state storage
outputs.tf           → Display results after apply
MODULE_ARCHITECTURE.md → Documentation
```

### VPC Module (`terraform/modules/vpc/`)
```
vpc.tf               → Network infrastructure (VPC, subnets, security groups)
outputs.tf           → Exposes: vpc_id, subnet_ids, security_group_ids
```

### EC2 Module (`terraform/modules/ec2/`)
```
ec2-instance.tf      → EC2 instance + SSH key
variables.tf         → Inputs: subnet_id, security_group_id, ami_id
outputs.tf           → Exposes: instance_id, private_ip
```

### ALB Module (`terraform/modules/alb/`)
```
main.tf              → Load balancer, target group, listener
variables.tf         → Inputs: vpc_id, subnet_ids, ec2_instance_id
outputs.tf           → Exposes: alb_dns_name, arn_suffix
```

### CloudFront Module (`terraform/modules/cloudfront/`)
```
cloudfront.tf        → CDN distribution
variables.tf         → Inputs: alb_dns_name
outputs.tf           → Exposes: cloudfront_domain_name ⭐
```

### SNS Module (`terraform/modules/sns/`)
```
sns.tf               → Notification topic + email subscription
outputs.tf           → Exposes: sns_topic_arn
```

### CloudWatch Module (`terraform/modules/cloudwatch/`)
```
cloudwatch.tf        → 4 monitoring alarms (CPU, response time, requests, health)
variables.tf         → Inputs: ec2_instance_id, alb_arn_suffix, sns_topic_arn
```

---

## Application Files (Docker)

### Root (`app/`)
```
docker-compose.yml   → Orchestrates 3 services: db, server, client
```

### Database (`app/database/`)
```
Dockerfile           → MySQL 8.0 container
init.sql             → Creates my_app_db + users table
```

### Server (`app/server/`)
```
Dockerfile           → Node.js 18 container
package.json         → Dependencies: express, mysql2, cors
index.js             → Express server with retry logic
db.js                → MySQL connection pool
routes/users.js      → User CRUD API
.env.example         → Environment template
schema.sql           → DB schema (for manual setup)
```

### Client (`app/client/`)
```
Dockerfile           → Multi-stage: Vite build → Nginx serve
package.json         → Dependencies: react, vite
vite.config.js       → Build configuration
index.html           → HTML entry point
src/main.jsx         → React entry point
src/App.jsx          → User registration form
src/App.css          → Glassmorphism styles
src/index.css        → Global styles
.env.example         → Environment template
```

---

## How Files Connect

### Terraform Flow
```
main.tf
  ├─→ module "vpc"        (creates network)
  ├─→ module "ec2"        (uses VPC outputs)
  ├─→ module "alb"        (uses VPC + EC2 outputs)
  ├─→ module "cloudfront" (uses ALB outputs)
  ├─→ module "sns"        (standalone)
  └─→ module "cloudwatch" (uses EC2 + ALB + SNS outputs)
```

### Application Flow
```
docker-compose.yml
  ├─→ db (MySQL)
  │    └─→ init.sql (creates database)
  │
  ├─→ server (Node.js)
  │    ├─→ index.js (Express app)
  │    ├─→ db.js (connects to MySQL)
  │    └─→ routes/users.js (API endpoints)
  │
  └─→ client (React)
       ├─→ src/App.jsx (UI)
       └─→ calls server API
```

---

## Key Files to Know

### For Infrastructure Changes
- `terraform/main.tf` - Module connections
- `terraform/variables.tf` - Change region or AMI
- `terraform/modules/*/variables.tf` - Module inputs

### For Application Changes
- `app/docker-compose.yml` - Service configuration
- `app/server/index.js` - Backend logic
- `app/client/src/App.jsx` - Frontend UI

### For Deployment
- `terraform/outputs.tf` - See what URLs you'll get
- `app/server/.env.example` - Configure database
- `app/client/.env.example` - Configure API URL

---

## Status: ✅ ALL FILES VERIFIED

**Terraform:** Valid and ready to deploy  
**Application:** Docker-ready 3-tier stack  
**Documentation:** Complete
