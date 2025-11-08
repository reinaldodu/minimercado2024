FROM php:8.2-fpm

# Instalación de paquetes de sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev

# Extensiones de PHP
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Instalar Node.js (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Directorio de trabajo
WORKDIR /var/www

# Copiar archivos de dependencias
COPY composer.json composer.lock ./
COPY package.json package-lock.json* ./

# Instalar dependencias PHP (incluye dev)
RUN composer install

# Instalar dependencias Node
RUN npm install

# Copiar todo el proyecto
COPY . .

# Permisos en storage y cache
RUN chmod -R 777 storage bootstrap/cache

CMD ["php-fpm"]
