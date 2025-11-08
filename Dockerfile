# Imagen base PHP-FPM
FROM php:8.2-fpm

# Dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    zip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev

# Extensiones PHP típicas de Laravel
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Instalar Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Directorio de trabajo
WORKDIR /var/www

# Usuario para evitar problemas de permisos
RUN useradd -ms /bin/bash www && chown -R www:www /var/www

USER www
