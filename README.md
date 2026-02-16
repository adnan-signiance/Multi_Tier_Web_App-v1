# Multi-Tier Web App

This is a 3-tier web application with:
- **Frontend**: React (Vite) with modern UI/UX
- **Backend**: Node.js & Express
- **Database**: MySQL

## Prerequisites

- Node.js installed
- MySQL Server installed and running locally on port 3306

## Setup & Run (Docker)

Recommended way to run the application.

1.  **Environment Setup**
    Copy the example environment file and customize it:
    ```bash
    cp .env.example .env
    # Edit .env with your configuration (optional - has sensible defaults)
    ```

2.  **Start Services**
    Build and start the application using Docker Compose:
    ```bash
    docker-compose up --build
    ```

    The application will be available at:
    -   Frontend: [http://localhost](http://localhost) (port 80)
    -   Backend API: [http://localhost:5000](http://localhost:5000)
    -   Database: localhost:3307

**Note:** All ports and configuration can be customized via the `.env` file.

## Manual Setup (Local Development)

### 1. Database Setup
Ensure MySQL is running locally on port 3306. Create the database:
```bash
mysql -u root -p < server/schema.sql
```
Update `server/.env` with your local database credentials.

### 2. Backend Setup
Navigate to the server directory:
```bash
cd server
cp .env.example .env
npm install
npm run dev
```

### 3. Frontend Setup
Navigate to the client directory:
```bash
cd client
cp .env.example .env
npm install
npm run dev
```

## Features
-   Modern Glassmorphism UI
-   User Registration (Name, Email, Phone, Age)
-   Real-time User List
-   Form Validation & Error Handling
-   Production-ready Docker configuration
-   Full AWS infrastructure as code (Terraform)
-   CloudWatch monitoring with SNS alerts
-   CloudFront CDN distribution

## AWS Deployment (Terraform)

Deploy the infrastructure to AWS using Terraform:

1.  **Configure Variables**
    ```bash
    cd terraform
    cp terraform.tfvars.example terraform.tfvars
    # Edit terraform.tfvars with your AWS configuration
    ```

2.  **Initialize and Deploy**
    ```bash
    terraform init
    terraform plan    # Review changes
    terraform apply   # Deploy to AWS
    ```

3.  **Get Outputs**
    After deployment, Terraform will display:
    - CloudFront domain name (your application URL)
    - ALB DNS name
    - EC2 instance ID
    - VPC ID

See `terraform/MODULE_ARCHITECTURE.md` for detailed infrastructure documentation.

## Best Practices

This project follows infrastructure and application best practices:
- ✅ No hardcoded values - all configuration via variables
- ✅ Environment-specific configurations
- ✅ Secure secret management
- ✅ Modular Terraform architecture
- ✅ Comprehensive monitoring and alerting

See `BEST_PRACTICES.md` for detailed documentation.
