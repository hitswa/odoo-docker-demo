#!/bin/bash

# Set environment variables
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres
export POSTGRES_DB=postgres
export ODOO_DB_USER=odoo
export ODOO_DB_PASSWORD=odoo
export ODOO_DB_NAME=odoo
export ODOO_PORT=8069

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker and try again."
    exit 1
fi

# Check if Docker service is running
docker info &> /dev/null
if [ $? -ne 0 ]; then
    echo "Docker service is not running. Please start Docker and try again."
    exit 1
fi

# Start the Docker Compose services
docker-compose up -d

# Wait for the PostgreSQL service to start
echo "Waiting for PostgreSQL to become available..."
count=0
until docker-compose exec postgres pg_isready -U postgres -d postgres -q || [ $count -eq 30 ]; do
    sleep 1
    ((count++))
done

if [ $count -eq 30 ]; then
    echo "Timed out waiting for PostgreSQL to become available."
    exit 1
fi

# Connect to the PostgreSQL container and execute SQL commands
# docker-compose exec postgres psql -U postgres -d postgres -c "CREATE ROLE $POSTGRES_USER WITH SUPERUSER LOGIN PASSWORD '$POSTGRES_PASSWORD';"
docker-compose exec postgres psql -U postgres -d postgres -c "CREATE DATABASE $POSTGRES_DB;"
docker-compose exec postgres psql -U postgres -d postgres -c "CREATE USER $ODOO_DB_USER WITH PASSWORD '$ODOO_DB_PASSWORD';"
docker-compose exec postgres psql -U postgres -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE $ODOO_DB_NAME TO $ODOO_DB_USER;"
docker-compose exec postgres psql -U postgres -d postgres -c "ALTER USER $ODOO_DB_USER CREATEDB;"

# Restart the Odoo service to apply the changes
docker-compose restart odoo

# Define the URL you want to open
URL="http://127.0.0.1:${ODOO_PORT}"

# Open the URL in the default browser
xdg-open "$URL"
