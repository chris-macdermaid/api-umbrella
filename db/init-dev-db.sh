#!/bin/bash
# Initialize the development database with users and permissions
# This script runs automatically when the postgres container is first created

set -e

# Create the api_umbrella database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create database
    CREATE DATABASE api_umbrella;

    -- Set password encryption to md5 for compatibility with lua-resty-postgres
    SET password_encryption = 'md5';

    -- Create migration/owner role
    CREATE ROLE api_umbrella_owner WITH 
        NOSUPERUSER NOCREATEDB NOCREATEROLE 
        INHERIT LOGIN NOREPLICATION NOBYPASSRLS 
        PASSWORD 'dev_password';

    -- Create application role
    CREATE ROLE api_umbrella_app WITH 
        NOSUPERUSER NOCREATEDB NOCREATEROLE 
        INHERIT LOGIN NOREPLICATION NOBYPASSRLS 
        PASSWORD 'dev_password';

    -- Grant app role to owner (for ownership transfers)
    GRANT api_umbrella_app TO api_umbrella_owner WITH ADMIN OPTION;

    -- Grant database privileges
    GRANT ALL PRIVILEGES ON DATABASE api_umbrella TO api_umbrella_owner;
    GRANT ALL PRIVILEGES ON DATABASE api_umbrella TO api_umbrella_app;
EOSQL

# Connect to api_umbrella database and set up schemas
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "api_umbrella" <<-EOSQL
    -- Create schemas
    CREATE SCHEMA IF NOT EXISTS api_umbrella AUTHORIZATION api_umbrella_owner;
    CREATE SCHEMA IF NOT EXISTS audit AUTHORIZATION api_umbrella_owner;

    -- Set search path
    ALTER DATABASE api_umbrella SET search_path TO api_umbrella, public;

    -- Grant schema privileges to owner
    GRANT ALL ON SCHEMA api_umbrella TO api_umbrella_owner;
    GRANT ALL ON SCHEMA audit TO api_umbrella_owner;
    GRANT ALL ON SCHEMA public TO api_umbrella_owner;

    -- Grant schema privileges to app
    GRANT USAGE ON SCHEMA api_umbrella TO api_umbrella_app;
    GRANT USAGE ON SCHEMA audit TO api_umbrella_app;
    GRANT USAGE ON SCHEMA public TO api_umbrella_app;
EOSQL

# Configure pg_hba.conf for md5 authentication from Docker networks
# This is needed because lua-resty-postgres doesn't support scram-sha-256
cat >> "$PGDATA/pg_hba.conf" <<-EOF

# Allow md5 authentication for Docker networks (for lua-resty-postgres compatibility)
host all all 172.16.0.0/12 md5
EOF

echo "Development database initialized successfully"
