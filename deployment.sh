#!/bin/bash

# Function to update repository of the machine
update_repository() {
    sudo apt update
}

# Function to install Apache
install_apache() {
    sudo apt -y install apache2
}

# Function to install MySQL database
install_mysql() {
    sudo apt -y install mysql-server mysql-client
}

# Function to install PHP and extensions
install_php() {
    sudo apt install software-properties-common --yes
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt update
    sudo apt -y install php8.2 php8.2-curl php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip
}

# Function to enable URL rewriting
enable_url_rewriting() {
    sudo a2enmod rewrite
}

# Function to restart Apache
restart_apache() {
    sudo systemctl restart apache2
}

# Function to install Composer
install_composer() {
    cd /usr/bin
    curl -sS https://getcomposer.org/installer | sudo php -q
    if [ ! -f "composer" ]; then
        sudo mv composer.phar composer
    fi
}

# Function to clone the Laravel repository
clone_laravel_repo() {
    sudo chown -R $USER:$USER /var/www
    cd /var/www
    if [ ! -d "laravel" ]; then
       git clone https://github.com/laravel/laravel.git
    fi
}

# Function to install Composer in the Laravel project directory
install_composer_in_project() {
    cd /var/www/laravel
    composer install --optimize-autoloader --no-dev --no-interaction
    composer update --no-interaction
}

# Function to build the .env file
build_env_file() {
    cd /var/www/laravel
    if [ ! -f ".env" ]; then
        cp .env.example .env
    fi
}

# Function to set permissions
set_permissions() {
    sudo chown -R www-data storage
    sudo chown -R www-data bootstrap/cache
}

# Function to create the Apache config file
create_apache_config() {
    sudo bash -c 'cat > /etc/apache2/sites-available/laravel.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName localhost
    ServerAlias localhost
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>
EOF'
}

# Function to enable the new Apache config
enable_apache_config() {
    sudo a2dissite 000-default.conf
    sudo rm 000-default.conf
    sudo a2ensite laravel.conf
}

# Function to restart MySQL
restart_mysql() {
    sudo systemctl start mysql
}

# Function to create database and user
create_database_and_user() {
    sudo mysql -uroot -e "CREATE DATABASE IF NOT EXISTS laravel;"
    sudo mysql -uroot -e "CREATE USER IF NOT EXISTS 'vagrant'@'localhost' IDENTIFIED BY '1805';"
    sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON laravel.* TO 'vagrant'@'localhost';"
}

# Function to update .env file with MySQL connection details
update_env_file() {
    cd /var/www/laravel
    grep -qF 'DB_CONNECTION=mysql' .env && sed -i 's/DB_CONNECTION=mysql/DB_CONNECTION=mysql/' .env || echo "DB_CONNECTION=mysql" >> .env
    grep -qF 'DB_HOST=localhost' .env && sed -i 's/DB_HOST=localhost/DB_HOST=localhost/' .env || echo "DB_HOST=localhost" >> .env
    grep -qF 'DB_PORT=3306' .env && sed -i 's/DB_PORT=3306/DB_PORT=3306/' .env || echo "DB_PORT=3306" >> .env
    grep -qF 'DB_DATABASE=laravel' .env && sed -i 's/DB_DATABASE=laravel/DB_DATABASE=laravel/' .env || echo "DB_DATABASE=laravel" >> .env
    grep -qF 'DB_USERNAME=vagrant' .env && sed -i 's/DB_USERNAME=vagrant/DB_USERNAME=vagrant/' .env || echo "DB_USERNAME=vagrant" >> .env
    grep -qF 'DB_PASSWORD=1805' .env && sed -i 's/DB_PASSWORD=1805/DB_PASSWORD=1805/' .env || echo "DB_PASSWORD=1805" >> .env
}

# Function to generate application key
generate_application_key() {
    cd /var/www/laravel
    sudo php artisan key:generate
}

# Function to create symbolic link for storage
create_storage_link() {
    cd /var/www/laravel
    sudo php artisan storage:link
}

# Function to run migrations
run_migrations() {
    cd /var/www/laravel
    sudo php artisan migrate --force
}

# Function to seed the database
seed_database() {
    cd /var/www/laravel
    sudo php artisan db:seed --force
}

# Function to restart Apache
restart_apache() {
    sudo systemctl restart apache2
}

# Main script execution
update_repository
install_apache
install_mysql
install_php
enable_url_rewriting
restart_apache
install_composer
clone_laravel_repo
install_composer_in_project
build_env_file
set_permissions
create_apache_config
enable_apache_config
restart_mysql
create_database_and_user
update_env_file
generate_application_key
create_storage_link
run_migrations
seed_database
restart_apache
