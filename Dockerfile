FROM php:8.4-fpm-alpine

# 1. Laufzeit-Abhängigkeiten für TYPO3 installieren
RUN apk add --no-cache \
    imagemagick \
    graphicsmagick \
    ghostscript \
    libpng \
    libjpeg-turbo \
    libwebp \
    freetype \
    libzip \
    icu-libs \
    libpq \
    bash \
    git \
    curl

# 2. Build-Abhängigkeiten temporär installieren, Extensions bauen und aufräumen
RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        postgresql-dev \
        icu-dev \
        libzip-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        libwebp-dev \
        freetype-dev \
        imagemagick-dev \
        pkgconf \
    # Imagick stabil über PECL für PHP 8.4 installieren
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    # GD-Extension konfigurieren und alle TYPO3-Extensions installieren
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        pdo_pgsql \
        intl \
        gd \
        zip \
        opcache \
        bcmath \
        exif \
    # Temporäre Build-Pakete und PECL-Cache restlos entfernen
    && apk del .build-deps \
    && rm -rf /tmp/pear

# 3. ImageMagick Policy anpassen (Wichtig für TYPO3 PDF-Vorschauen / Falldown-Rendings)
RUN sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' /etc/ImageMagick-7/policy.xml

WORKDIR /var/www/html
