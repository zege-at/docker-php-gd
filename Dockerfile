# ==========================================
# STAGE 1: Builder (Kompiliert alle Extensions)
# ==========================================
FROM php:8.4-fpm-alpine AS builder

# Alle Build-Abhängigkeiten temporär installieren
RUN apk add --no-cache \
    $PHPIZE_DEPS \
    postgresql-dev \
    icu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    imagemagick-dev \
    pkgconf

# Imagick via PECL installieren & Standard-Extensions bauen
RUN pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        pdo_pgsql \
        intl \
        gd \
        zip \
        opcache \
        bcmath \
        exif


# ==========================================
# STAGE 2: Finales Production Image
# ==========================================
FROM php:8.4-fpm-alpine

# 1. Nur die reinen Laufzeit-Pakete installieren (keine -dev Pakete, kein gcc, kein Make)
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

# 2. Fertig kompilierte Extensions & PHP-Configs aus der Builder-Stage kopieren
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# 3. ImageMagick Policy anpassen (Wichtig für TYPO3 PDF-Vorschauen)
RUN sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' /etc/ImageMagick-7/policy.xml

WORKDIR /var/www/html
