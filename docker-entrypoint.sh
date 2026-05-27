#!/bin/sh
set -e

cd /var/www/html

# If .env is missing but .env.docker exists, copy it
if [ ! -f .env ] && [ -f .env.docker ]; then
  cp .env.docker .env
  echo "Copied .env.docker to .env"
fi

# Install composer dependencies if vendor not present
if [ ! -d "vendor" ]; then
  echo "Installing Composer dependencies..."
  composer install --no-interaction --prefer-dist --optimize-autoloader || true
fi

# Generate APP_KEY if missing
if [ -f .env ]; then
  KEY=$(php -r "require 'vendor/autoload.php'; echo getenv('APP_KEY');" 2>/dev/null || true)
  if [ -z "$KEY" ]; then
    php artisan key:generate --force || true
  fi
fi

# Wait for DB to be ready (try PDO connection using the configured driver)
echo "Waiting for database..."
TRIES=0
MAX_TRIES=30
until php -r '
$driver = getenv("DB_CONNECTION") ?: "mysql";
$host = getenv("DB_HOST");
$port = getenv("DB_PORT");
$database = getenv("DB_DATABASE");
$username = getenv("DB_USERNAME");
$password = getenv("DB_PASSWORD");

if ($driver === "sqlsrv") {
    $dsn = "sqlsrv:Server={$host},{$port};Database={$database}";
} else {
    $dsn = "mysql:host={$host};port={$port};dbname={$database}";
}

new PDO($dsn, $username, $password);
echo "ok";
' >/dev/null 2>&1; do
  TRIES=$((TRIES+1))
  if [ "$TRIES" -ge "$MAX_TRIES" ]; then
    echo "Database did not become available - continuing anyway"
    break
  fi
  sleep 2
done

# Run migrations/seeds only when explicitly enabled
if [ "${RUN_DB_MIGRATIONS:-false}" = "true" ]; then
  echo "Running migrations and seeders..."
  php artisan migrate --force || true
  php artisan db:seed --force || true
fi

exec "$@"
