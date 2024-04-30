FROM php:7.1-fpm-buster

# Setup timezone
ENV TZ="Asia/Kuala_Lumpur"

# install composer
COPY --from=composer:lts /usr/bin/composer /usr/local/bin/composer

# copy fonts
COPY ./fonts/ /usr/share/fonts/truetype/buildspace/

# Install utility and libs needed by PHP extension
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
    zlib1g-dev \
    libzip-dev \
    xfonts-base \
    xfonts-75dpi\
    unzip \
    unoconv \
    multiarch-support \
    ca-certificates \
    git \
    gettext-base \
    wget && \
    apt-get install -y --force-yes libreoffice --no-install-recommends && \
    curl "https://archive.debian.org/debian/pool/main/libp/libpng/libpng12-0_1.2.50-2+deb8u3_amd64.deb" -L -o "libpng12.deb" && \
    dpkg -i libpng12.deb && \
    rm -rf libpng12.deb && \
    curl "https://archive.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1e-2+deb7u20_amd64.deb" -L -o "libssl1.deb" && \
    dpkg -i libssl1.deb && \
    rm -rf libssl1.deb && \
    curl "https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb" -L -o "wkhtmltox.deb" && \
    dpkg -i wkhtmltox.deb && \
    rm -rf wkhtmltox.deb && \
    ln -s /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf && \
    rm -rf /var/lib/apt/lists/*

# install some base extensions
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN IPE_GD_WITHOUTAVIF=1 install-php-extensions gmp gd zip pdo_pgsql pgsql pcntl mcrypt intl

# install pear extensions
RUN pear channel-update pear.php.net && pear install Numbers_Words-0.18.1

# install libsodium
RUN wget --secure-protocol=TLSv1_2 https://download.libsodium.org/libsodium/releases/libsodium-1.0.18-stable.tar.gz && \
    tar xzvf libsodium-1.0.18-stable.tar.gz && \
    cd libsodium-stable/ && \
    ./configure && \
    make && \
    make check && \
    make install && \
    pecl install libsodium && \
    cd .. && \
    rm -rf libsodium-1.0.18-stable.tar.gz libsodium-stable && \
    echo "extension=sodium.so" > /usr/local/etc/php/conf.d/docker-php-ext-sodium.ini
