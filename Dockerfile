FROM php:8.5-fpm-alpine

# 1. Nur LAUFZEIT-Abhängigkeiten installieren (Diese bleiben permanent im Image)
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

# 2. Build-Abhängigkeiten temporär installieren, Extensions bauen und sauber aufräumen
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
    && git clone https://github.com/Imagick/imagick.git \
    && cd imagick \
    && phpize && ./configure \
    && make && make install \
    && docker-php-ext-enable imagick \
    && cd .. && rm -rf imagick \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        pdo_pgsql \
        intl \
        gd \
        zip \
        opcache \
        bcmath \
    && apk del .build-deps

# ImageMagick Policy anpassen (für PDF Verarbeitung)
RUN sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' /etc/ImageMagick-7/policy.xml

WORKDIR /var/www/html

