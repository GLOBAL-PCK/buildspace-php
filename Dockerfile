FROM --platform=linux/amd64 php:7.1.30-fpm-jessie

# Setup timezone
ENV TZ="Asia/Kuala_Lumpur"

# Replace debian package URL
RUN sed -i s/deb.debian.org/archive.debian.org/g /etc/apt/sources.list
RUN sed -i 's|security.debian.org|archive.debian.org/|g' /etc/apt/sources.list
RUN sed -i '/jessie-updates/d' /etc/apt/sources.list

# Install utility and libs needed by PHP extension
RUN apt-get update && apt-get install -y --force-yes \
    build-essential \
    zlib1g-dev \
    libzip-dev \
    xfonts-base \
    xfonts-75dpi\
    libpng12-0 \
    libjpeg62-turbo \
    libssl1.0.0 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    fontconfig \
    unzip \
    unoconv \
    wget \
    curl && \
    apt-get install -y --force-yes libreoffice --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# install composer
COPY --from=composer:lts /usr/bin/composer /usr/local/bin/composer

# install some base extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && IPE_GD_WITHOUTAVIF=1 install-php-extensions @fix_letsencrypt mcrypt gmp gd zip pdo_mysql pdo_pgsql pgsql

# install pear extensions
RUN pear channel-update pear.php.net && pear install Numbers_Words-0.18.1

# install libsodium
RUN wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.18-stable.tar.gz && \
    tar xzvf libsodium-1.0.18-stable.tar.gz && \
    cd libsodium-stable/ && \
    ./configure && \
    make && \
    make check && \
    make install && \
    pecl install libsodium

# Download and extract wkhtmltopdf
RUN curl "https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb" -L -o "wkhtmltox.deb" && \
    dpkg -i wkhtmltox.deb && \
    rm -rf wkhtmltox.deb \
