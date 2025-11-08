# Etapa 1: Build de dependencias (PHP + Composer + Node)
FROM php:8.2-fpm as builder

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev

# Instalar Node.js (LTS estable)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs

# Instalar extensiones de PHP
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establecer directorio de trabajo
WORKDIR /var/www

# Copiar archivos de dependencias
COPY package.json package-lock.json* ./
COPY composer.json composer.lock ./

# Instalar dependencias Node
RUN npm install

# Instalar dependencias PHP (sin dev)
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Etapa 2: Imagen final
FROM php:8.2-fpm

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Crear usuario para la aplicación
RUN groupadd -g 1000 www && \
    useradd -u 1000 -ms /bin/bash -g www www

# Directorio de trabajo
WORKDIR /var/www

# Copiar vendor desde builder
COPY --from=builder /var/www/vendor ./vendor

# Copiar node_modules desde builder
COPY --from=builder /var/www/node_modules ./node_modules

# Copiar archivos de la aplicación
COPY --chown=www:www . .

# Copiar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Generar autoload optimizado
RUN composer dump-autoload --optimize

# Configurar permisos
RUN chown -R www:www /var/www && \
    chmod -R 755 /var/www/storage && \
    chmod -R 755 /var/www/bootstrap/cache

# Cambiar al usuario www
USER www

CMD ["php-fpm"]
