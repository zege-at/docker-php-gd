FROM php:8.3-fpm-alpine

# Abhängigkeiten installieren (Postgres, Grafik, Zip, Intl)
RUN apk add --no-cache \
    postgresql-dev \
    icu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    imagemagick \
    imagemagick-dev \
    graphicsmagick \
    ghostscript

# PHP Extensions installieren
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_pgsql \
        intl \
        gd \
        zip \
        opcache \
        bcmath \
    && apk del .build-deps

# ImageMagick Policy anpassen (für PDF Verarbeitung in TYPO3 oft nötig)
# (Optional, falls TYPO3 PDFs generieren/lesen soll)
RUN sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' /etc/ImageMagick-7/policy.xml

WORKDIR /var/www/html
