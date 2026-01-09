FROM php:8.4-fpm-alpine

# Abhängigkeiten für GD (Bilder verarbeiten) installieren
RUN apk add --no-cache \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev

# PHP Extension GD konfigurieren und installieren
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd

# Berechtigungen sicherstellen (optional, aber gut für Cache-Ordner)
RUN chown -R www-data:www-data /var/www/html
