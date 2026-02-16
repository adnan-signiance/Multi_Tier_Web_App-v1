# Terraform Module Architecture

## Module Dependency Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         ROOT MODULE                              │
│                        (main.tf)                                 │
└─────────────────────────────────────────────────────────────────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
                ▼               ▼               ▼
        ┌───────────┐   ┌───────────┐   ┌───────────┐
        │    VPC    │   │    SNS    │   │           │
        │  Module   │   │  Module   │   │           │
        └───────────┘   └───────────┘   │           │
                │                        │           │
                │ outputs:               │           │
                │ - vpc_id               │           │
                │ - subnet_ids           │           │
                │ - security_group_ids   │           │
                │                        │           │
                ▼                        │           │
        ┌───────────┐                   │           │
        │    EC2    │                   │           │
        │  Module   │                   │           │
        └───────────┘                   │           │
                │                        │           │
                │ outputs:               │           │
                │ - instance_id          │           │
                │ - private_ip           │           │
                │                        │           │
                ▼                        │           │
        ┌───────────┐                   │           │
        │    ALB    │                   │           │
        │  Module   │                   │           │
        └───────────┘                   │           │
                │                        │           │
                │ outputs:               │           │
                │ - alb_dns_name         │           │
                │ - alb_arn_suffix       │           │
                │ - tg_arn_suffix        │           │
                │                        │           │
                ├────────────────────────┼───────────┤
                │                        │           │
                ▼                        ▼           ▼
        ┌───────────┐           ┌──────────────────────┐
        │CloudFront │           │    CloudWatch        │
        │  Module   │           │      Module          │
        └───────────┘           └──────────────────────┘
```

## Module Connections

### 1. **VPC Module** (Foundation)
- **Inputs:** None
- **Outputs:** 
  - `vpc_id`
  - `public_subnet_1_id`, `public_subnet_2_id`
  - `private_subnet_id`
  - `alb_security_group_id`
  - `ec2_security_group_id`
- **Resources Created:**
  - VPC, Internet Gateway
  - 2 Public Subnets, 1 Private Subnet
  - Route Tables & Associations
  - Security Groups (ALB & EC2)

### 2. **EC2 Module**
- **Inputs:** 
  - `subnet_id` ← from VPC module
  - `security_group_id` ← from VPC module
  - `ami_id` ← from root variables
  - `instance_type`
- **Outputs:**
  - `instance_id`
  - `instance_private_ip`
- **Resources Created:**
  - SSH Key Pair
  - EC2 Instance

### 3. **ALB Module**
- **Inputs:**
  - `vpc_id` ← from VPC module
  - `public_subnet_ids` ← from VPC module
  - `alb_security_group_id` ← from VPC module
  - `ec2_instance_id` ← from EC2 module
- **Outputs:**
  - `alb_dns_name`
  - `alb_arn_suffix`
  - `target_group_arn_suffix`
- **Resources Created:**
  - Application Load Balancer
  - Target Group
  - Listener
  - Target Group Attachment

### 4. **CloudFront Module**
- **Inputs:**
  - `alb_dns_name` ← from ALB module
- **Outputs:**
  - `cloudfront_domain_name`
  - `cloudfront_id`
- **Resources Created:**
  - CloudFront Distribution

### 5. **SNS Module**
- **Inputs:** None
- **Outputs:**
  - `sns_topic_arn`
- **Resources Created:**
  - SNS Topic
  - Email Subscription

### 6. **CloudWatch Module**
- **Inputs:**
  - `ec2_instance_id` ← from EC2 module
  - `alb_arn_suffix` ← from ALB module
  - `target_group_arn_suffix` ← from ALB module
  - `sns_topic_arn` ← from SNS module
- **Outputs:** None
- **Resources Created:**
  - 4 CloudWatch Alarms:
    - EC2 CPU High
    - ALB Response Time High
    - ALB Request Count High
    - ALB Unhealthy Hosts

## Deployment Order

Terraform automatically handles the dependency order:

1. **VPC Module** (no dependencies)
2. **SNS Module** (no dependencies)
3. **EC2 Module** (depends on VPC)
4. **ALB Module** (depends on VPC + EC2)
5. **CloudFront Module** (depends on ALB)
6. **CloudWatch Module** (depends on EC2 + ALB + SNS)

## Usage

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply infrastructure
terraform apply

# Destroy infrastructure
terraform destroy
```

## Key Outputs After Apply

- **cloudfront_domain_name**: Your application's public URL
- **alb_dns_name**: Direct ALB access (for testing)
- **ec2_instance_id**: EC2 instance identifier
- **sns_topic_arn**: Notification topic ARN
