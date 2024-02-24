@echo off

:: Set environment variables
SET POSTGRES_USER=postgres
SET POSTGRES_PASSWORD=postgres
SET POSTGRES_DB=postgres
SET ODOO_DB_USER=odoo
SET ODOO_DB_PASSWORD=odoo
SET ODOO_DB_NAME=odoo
SET ODOO_PORT=8069

:: Check if Docker is installed
docker --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Docker is not installed. Please install Docker and try again.
    exit /b 1
)

:: Check if Docker service is running
docker info >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Docker service is not running. Please start Docker and try again.
    exit /b 1
)

:: Start the Docker Compose services
docker-compose up -d

:: Wait for the PostgreSQL service to start
echo Waiting for PostgreSQL to become available...
set count=0
:loop
docker-compose exec postgres pg_isready -U postgres -d postgres -q
if %ERRORLEVEL% neq 0 (
    set /a count+=1
    if %count% equ 30 (
        echo Timed out waiting for PostgreSQL to become available.
        exit /b 1
    )
    timeout /t 1 >nul
    goto loop
)

:: Connect to the PostgreSQL container and execute SQL commands
docker-compose exec postgres psql -U postgres -d postgres -c "CREATE DATABASE %POSTGRES_DB%;"
docker-compose exec postgres psql -U postgres -d postgres -c "CREATE USER %ODOO_DB_USER% WITH PASSWORD '%ODOO_DB_PASSWORD%';"
docker-compose exec postgres psql -U postgres -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE %ODOO_DB_NAME% TO %ODOO_DB_USER%;"
docker-compose exec postgres psql -U postgres -d postgres -c "ALTER USER %ODOO_DB_USER% CREATEDB;"

:: Restart the Odoo service to apply the changes
docker-compose restart odoo

:: Define the URL you want to open
set URL="http://127.0.0.1:%ODOO_PORT%"

:: Open the URL in the default browser
start "" "%URL%"