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
    Copy the example environment files to create your local configuration:
    ```bash
    cp client/.env.example client/.env
    cp server/.env.example server/.env
    ```

2.  **Start Services**
    Build and start the application using Docker Compose:
    ```bash
    docker-compose up --build
    ```

    The application will be available at:
    -   Frontend: [http://localhost:5173](http://localhost:5173)
    -   Backend API: [http://localhost:5000](http://localhost:5000)

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
