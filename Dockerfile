# Use official Node.js image as the base image
FROM node:18-alpine as builder

# Install required dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    openssh-client

# Create app directory
WORKDIR /usr/src/app

# Install n8n
RUN npm install -g n8n@latest

# Create a non-root user
RUN addgroup -S n8n && \
    adduser -S -G n8n n8n && \
    mkdir -p /home/n8n/.n8n && \
    chown -R n8n:n8n /home/n8n

# Switch to non-root user
USER n8n

# Set environment variables
ENV NODE_ENV=production \
    N8N_PORT=5678 \
    NODE_FUNCTION_ALLOW_EXTERNAL=uuid \
    DB_TYPE=postgresdb \
    GENERIC_TIMEZONE=${GENERIC_TIMEZONE:-UTC} \
    DB_POSTGRESDB_HOST=postgres \
    DB_POSTGRESDB_PORT=5432 \
    EXECUTIONS_MODE=queue \
    QUEUE_BULL_REDIS_HOST=redis \
    QUEUE_HEALTH_CHECK_ACTIVE=true \
    EXECUTIONS_DATA_PRUNE=false

# Expose port
# EXPOSE 5678



EXPOSE $PORT
# If a hard coded port is set it will break cloud run - use this dynamic variable


# Set healthcheck
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD wget --spider http://localhost:5678/healthz || exit 1

# Command to run n8n
CMD ["n8n", "start"]
