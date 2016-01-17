#!/bin/bash
cd "$(dirname "${BASH_SOURCE}")"
mkdir -p migrations

migration_name=$(date +%s)_$1.sql
touch "migrations/$migration_name"
echo "Created migration $migration_name."
