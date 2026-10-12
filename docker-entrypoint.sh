#!/bin/bash
set -e

# Railway gives the port in $PORT
PORT="${PORT:-80}"
sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Railway MySQL variables: MYSQLHOST MYSQLPORT MYSQLUSER MYSQLPASSWORD MYSQLDATABASE
# NOTE: variable names below follow the classic mirzabot config.php.
# Compare with the config.php in your repo and adjust if they differ.
cat > /var/www/html/config.php <<PHP
<?php
\$dbname = '${MYSQLDATABASE}';
\$usernamedb = '${MYSQLUSER}';
\$passworddb = '${MYSQLPASSWORD}';
\$dbhost = '${MYSQLHOST}';
\$dbport = '${MYSQLPORT:-3306}';

\$connect = mysqli_connect(\$dbhost, \$usernamedb, \$passworddb, \$dbname, (int)\$dbport);
if (\$connect->connect_error) { die("error" . \$connect->connect_error); }
mysqli_set_charset(\$connect, "utf8mb4");

\$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
];
\$dsn = "mysql:host=\$dbhost;port=\$dbport;dbname=\$dbname;charset=utf8mb4";
try { \$pdo = new PDO(\$dsn, \$usernamedb, \$passworddb, \$options); }
catch (\PDOException \$e) { error_log("DB error: " . \$e->getMessage()); }

\$APIKEY = '${BOT_TOKEN}';
\$adminnumber = '${ADMIN_ID}';
\$domainhosts = '${DOMAIN}';
\$usernamebot = '${BOT_USERNAME}';
?>
PHP

exec apache2-foreground
