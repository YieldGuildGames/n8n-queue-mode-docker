# n8n Docker Compose Setup in Queue Mode

## 1. Introduction

**What is n8n?**  
[n8n](https://n8n.io/) is a powerful, node-based workflow automation tool that enables you to easily automate tasks and integrate different services with minimal code. It supports a wide variety of triggers, actions, and third-party integrations, allowing you to quickly build complex workflows. Because n8n is source-available and extensible, it’s an ideal choice for developers looking to customize and self-host their own automation platform.

**Purpose of this Project**  
This project sets up an n8n instance configured in **queue mode**, enabling horizontal scaling of workflow executions and improving reliability. The environment is managed via Docker Compose, making it easy to deploy, manage, and maintain. Additionally, the project uses **Traefik** as a reverse proxy and **PostgreSQL** and **Redis** as a database and queue backend, respectively.

**What This Documentation Covers**  
In this documentation, you will learn how to:

- Understand the prerequisites and required tools.
- Clone this repository from GitHub.
- Configure environment variables for the queue mode setup.
- Run and verify the Docker Compose services.
- Troubleshoot common issues.
- Access additional learning resources.

Whether you’re new to containerization or an experienced Docker user, this guide will walk you through every step of deploying a self-hosted n8n instance in queue mode.

---

## 2. Prerequisites

To follow this guide, ensure you have the following:

- **Basic Knowledge of Docker**: Understanding Docker containers, images, and volumes.
- **Docker and Docker Compose Installed**:
  - Docker: [Install Docker](https://docs.docker.com/get-docker/)
  - Docker Compose: [Install Docker Compose](https://docs.docker.com/compose/install/)
- **GitHub Access**: You’ll need Git installed to clone the repository.
  - Git: [Install Git](https://git-scm.com/downloads)
- **Basic Linux/Unix Command Line Skills**: Familiarity with the terminal will help in running commands and editing files.
- **Domain Name (Optional)**: If you’re hosting this publicly, you’ll need a domain name with DNS records pointing to your server.
- **Valid SSL Email (For TLS Certificates)**: Traefik uses Let’s Encrypt for SSL certificates, so ensure you have an email address for registration.

**Note:** This setup is tested with `docker-compose.yml` provided in this project. Any variations in environment or version may require adjustments.

---

## 3. Setup Instructions

### 3.1 Cloning the Repository

1. Open your terminal or command prompt.
2. Navigate to the directory where you want to store the project.
3. Run the following command to clone the repository:
   ```bash
   git clone https://github.com/brandlabsapp/n8n-queue-mode-docker.git
   cd n8n-queue-mode-docker
   ```

### 3.2 Configuration of Environment Variables

1. **Create an `.env` file**:  
   In the project’s root directory (where `docker-compose.yml` is located), create a file named `.env` if it doesn’t already exist.
2. **Set Required Variables**:  
   Add your domain information, database credentials, and other required environment variables:

   ```bash
   # Example .env file

   # Domain and subdomain for accessing n8n
   DOMAIN_NAME=example.com
   SUBDOMAIN=n8n

   # SSL related
   SSL_EMAIL=you@example.com

   # Timezone configuration
   GENERIC_TIMEZONE=Europe/Berlin

   # Database Credentials
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=postgrespassword
   POSTGRES_DB=n8ndb
   POSTGRES_NON_ROOT_USER=n8nuser
   POSTGRES_NON_ROOT_PASSWORD=n8nuserpassword

   # Encryption Key (replace with a strong, unique key)
   N8N_ENCRYPTION_KEY=yourEncryptionKeyHere
   ```

   **Note:** Ensure you provide a valid and strong `N8N_ENCRYPTION_KEY`. This key is crucial for securing your workflow credentials.

3. **Check Permissions**:  
   Make sure your `.env` file has the correct permissions (generally `chmod 600 .env` is recommended on Linux). Keep this file secure, as it contains sensitive credentials.

### 3.3 Running the Docker Compose File

1. **Start Services**:  
   From the project’s root directory, run:

   ```bash
   docker compose up -d
   ```

   The `-d` flag runs the containers in detached mode (in the background).

2. **Check Logs**:  
   To verify that the services are running, check the logs:

   ```bash
   docker compose logs -f
   ```

   Press `Ctrl + C` to stop following logs.

3. **Healthchecks**:  
   The `postgres` and `redis` services have health checks. Wait for them to become healthy before the `n8n` and `n8n-worker` services start properly. Usually, this happens automatically; you can confirm by running:
   ```bash
   docker ps
   ```
   and checking the `STATUS` column.

---

## 4. Usage

### 4.1 Accessing the n8n Instance

Once the stack is running:

- Open your web browser and go to `https://n8n.example.com` (replace `n8n.example.com` with your actual subdomain and domain).
- You should see the n8n web UI.
- If you’ve provided correct domain and DNS settings, Traefik will have issued an SSL certificate from Let’s Encrypt, ensuring a secure connection.

### 4.2 Testing and Verifying the Setup

1. **Create a Simple Workflow**:  
   Log into the n8n UI and create a simple workflow that uses a trigger (like a Cron node) and a simple action (like an HTTP Request node).
2. **Run the Workflow**:

   - Execute the workflow manually or wait for the trigger to run it.
   - Check the `Executions` page in n8n to see if your workflow ran successfully.

3. **Queue Mode Validation**:
   - Since the setup uses a separate worker (`n8n-worker`), you can verify queue mode by checking the logs. Executions will be processed by the worker rather than the main `n8n` process.
   - Run:
     ```bash
     docker compose logs n8n-worker
     ```
     You should see logs indicating tasks are being processed by the worker.

---

## 5. Troubleshooting

**Common Issues & Solutions**

1. **SSL Certificate Not Issued**:

   - Make sure your domain name points correctly to your server’s IP.
   - Check that port 80 and 443 are open and accessible.
   - Verify that your `SSL_EMAIL` is valid.

2. **Database Connection Issues**:

   - Ensure that the `POSTGRES_USER`, `POSTGRES_PASSWORD`, and `POSTGRES_DB` values match the environment variables in the `.env` file.
   - If Postgres fails to start, check `docker compose logs postgres` for error messages.
   - Confirm that the `init-data.sh` script has the correct permissions:
     ```bash
     chmod +x init-data.sh
     ```

3. **Redis Healthcheck Fails**:

   - Check if Redis is running by reviewing logs:
     ```bash
     docker compose logs redis
     ```
   - If Redis is failing, ensure no other processes are using Redis’s ports (default is 6379).

4. **n8n Not Accessible via Domain**:

   - Check Traefik logs:
     ```bash
     docker compose logs traefik
     ```
   - Verify that `SUBDOMAIN` and `DOMAIN_NAME` are correctly set in `.env`.
   - Ensure DNS records are pointing to your server.

5. **Workflows Not Executing**:
   - Confirm that `EXECUTIONS_MODE=queue` is set in `.env`.
   - Check the `n8n-worker` logs to ensure tasks are being picked up.

---

## 6. Additional Resources

- **n8n Official Documentation**: [https://docs.n8n.io/](https://docs.n8n.io/)
- **Docker Compose Documentation**: [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
- **Traefik Documentation**: [https://doc.traefik.io/traefik/](https://doc.traefik.io/traefik/)
- **PostgreSQL Official Documentation**: [https://www.postgresql.org/docs/](https://www.postgresql.org/docs/)
- **Redis Official Documentation**: [https://redis.io/documentation](https://redis.io/documentation)
- **GitHub Repository Reference**: If you need to refer back to the repository, visit the GitHub page where you initially cloned it.

---

**You have successfully set up n8n in queue mode using Docker Compose!**
