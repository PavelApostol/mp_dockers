FROM alpine:3.12
ENV PHP_INI_DIR /usr/local/etc/php
ENV PHP_URL="https://www.php.net/distributions/php-7.4.10.tar.xz"
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"

RUN export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS";
RUN set -eux; addgroup -g 82 -S www-data; adduser -u 82 -D -S -G www-data www-data


RUN apk add --no-cache ca-certificates curl tar xz openssl;\
mkdir -p "$PHP_INI_DIR/conf.d" /var/www/html /usr/src/php; \
chown www-data:www-data /var/www/html; chmod 777 /var/www/html;\
cd /usr/src; \
curl -fSL -o php.tar.xz "$PHP_URL"; \
#распакуем
tar -Jxvf /usr/src/php.tar.xz -C /usr/src/php --strip-components=1;\
apk add --no-cache --virtual .build-deps \
autoconf dpkg-dev dpkg file g++ gcc libc-dev make \
pkgconf re2c argon2-dev coreutils curl-dev \
libedit-dev libsodium-dev libxml2-dev linux-headers \
oniguruma-dev openssl-dev sqlite-dev krb5-dev imap-dev \
libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev rabbitmq-c-dev; \
#компилируем
cd /usr/src/php; \
gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
./configure --build="$gnuArch" --with-config-file-path="$PHP_INI_DIR" --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" --enable-option-checking=fatal --with-mhash --enable-ftp --enable-mbstring --enable-mysqlnd --with-password-argon2 --with-pdo-sqlite=/usr --with-sqlite3=/usr --with-curl --with-libedit --with-openssl --with-zlib --with-pear --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --disable-cgi --with-kerberos --enable-bcmath --enable-calendar --with-imap --with-mysqli --enable-gd --with-webp --with-jpeg --with-freetype --with-imap-ssl; \
make -j 6; \
find -type f -name '*.a' -delete; \
make install; \
find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; \
make clean; \
cp -v php.ini-* "$PHP_INI_DIR/"; \
cd /; \
runDeps="$( \
scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u \
| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }')"; \
apk add --no-cache $runDeps; \
pecl update-channels; \
rm -rf /tmp/pear ~/.pearrc /usr/src/php; \
cd /usr/local/etc; \
cp php-fpm.conf.default php-fpm.conf; \
cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
sed -i 's!=NONE/!=!g' php-fpm.conf;\
{ \
echo '[global]'; \
echo 'error_log = /proc/self/fd/2'; \
echo 'log_limit = 8192'; \
echo '[www]'; \
echo 'access.log = /proc/self/fd/2'; \
echo 'clear_env = no'; \
echo 'catch_workers_output = yes'; \
echo 'decorate_workers_output = no'; \
} | tee php-fpm.d/docker.conf; \
\
{ \
echo '[global]'; \
echo 'daemonize = no'; \
echo '[www]'; \
echo 'listen = 9000'; \
} | tee php-fpm.d/zz-docker.conf; \
pecl install amqp; \
echo "zend_extension=opcache.so" > /usr/local/etc/php/conf.d/opcache.ini; \
echo "extension=amqp.so" > /usr/local/etc/php/conf.d/amqp.ini; \
apk del --no-network .build-deps; \
echo "memory_limit=1024M" >> /usr/local/etc/php/conf.d/php.ini; \
echo "upload_max_filesize=1024M" >> /usr/local/etc/php/php.ini; \
echo "post_max_size=1024M" >> /usr/local/etc/php/php.ini; 


STOPSIGNAL SIGQUIT

EXPOSE 9000
CMD ["php-fpm"]
