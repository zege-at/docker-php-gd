FROM php:8.5-fpm-alpine

# 1. Laufzeit-Abhängigkeiten installieren
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
    libpq

# 2. Build-Abhängigkeiten temporär installieren
RUN apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        postgresql-dev \
        icu-dev \
        libzip-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        libwebp-dev \
        freetype-dev \
        imagemagick-dev \
        git \
        pkgconf

# 3. Imagick separat klonen und kompilieren (Isolierter Schritt)
RUN git clone https://github.com/Imagick/imagick.git /tmp/imagick \
    && cd /tmp/imagick \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && docker-php-ext-enable imagick \
    && rm -rf /tmp/imagick

# 4. Standard PHP-Extensions konfigurieren und installieren
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        pdo_pgsql \
        intl \
        gd \
        zip \
        opcache \
        bcmath

# 5. Build-Abhängigkeiten in einem finalen Schritt aufräumen
RUN apk del .build-deps

# ImageMagick Policy anpassen (für PDF Verarbeitung)
RUN sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' /etc/ImageMagick-7/policy.xml

WORKDIR /var/www/html
