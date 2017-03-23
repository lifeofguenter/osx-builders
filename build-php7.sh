#!/usr/bin/env bash
#
# build php7 from source on osx
#

# php-version
version_php=7.0.17

# php-ext-versions
version_php_ext_igbinary=2.0.1
version_php_ext_apcu=5.1.8
version_php_ext_memcached=3.0.3
version_php_ext_redis=3.1.1
version_php_ext_phpiredis=1.0.0
version_php_ext_xdebug=2.5.1
version_php_ext_imagick=3.4.3

# libversions
version_imagemagick=7.0.5-3
version_pkg_config=0.29.1
version_automake=1.15
version_autoconf=2.69
version_libtool=2.4.6
version_libffi=3.2.1
version_pcre=8.40
version_glib=2.52.0
version_libressl=2.5.1
version_libicu=58.2
version_lzma=5.2.3
version_yasm=1.3.0
version_libjpeg=1.5.1
version_zlib=1.2.11
version_libpng=1.6.27
version_libtiff=4.0.7
version_libgif=5.1.4
version_pixman=0.34.0
version_cairo=1.15.4
version_pango=1.40.4
version_libxml=2.9.4
version_gdk_pixbuf=2.36.5
version_libcroco=0.6.11
version_librsvg=2.41.0
version_freetype=2.7.1
version_gettext=0.19.8.1
version_libmcrypt=2.5.8
version_libzip=1.2.0
version_apr=1.5.2
version_apr_util=1.5.4

__DIR__="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${__DIR__}/functions.shlib"

set -E
trap 'throw_exception' ERR

build_pkg_config() {
  cd "${__DIR__}/build"
  rm -rf "pkg-config-${version_pkg_config}"*
  curl -sSOLf "https://pkg-config.freedesktop.org/releases/pkg-config-${version_pkg_config}.tar.gz"
  tar xf "pkg-config-${version_pkg_config}.tar.gz"
  cd "pkg-config-${version_pkg_config}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    --with-internal-glib \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_automake() {
  cd "${__DIR__}/build"
  rm -rf "automake-${version_automake}"*
  curl -sSOLf "http://ftp.gnu.org/gnu/automake/automake-${version_automake}.tar.gz"
  tar xf "automake-${version_automake}.tar.gz"
  cd "automake-${version_automake}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_libtool() {
  cd "${__DIR__}/build"
  rm -rf "libtool-${version_libtool}"*
  curl -sSOLf "http://ftpmirror.gnu.org/libtool/libtool-${version_libtool}.tar.gz"
  tar xf "libtool-${version_libtool}.tar.gz"
  cd "libtool-${version_libtool}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    --enable-ltdl-install \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_libffi() {
  cd "${__DIR__}/build"
  rm -rf "libffi-${version_libffi}"*
  curl -sSOLf "ftp://sourceware.org/pub/libffi/libffi-${version_libffi}.tar.gz"
  tar xf "libffi-${version_libffi}.tar.gz"
  cd "libffi-${version_libffi}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_pcre() {
  cd "${__DIR__}/build"
  rm -rf "pcre-${version_pcre}"*
  curl -sSOLf "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${version_pcre}.tar.gz"
  tar xf "pcre-${version_pcre}.tar.gz"
  cd "pcre-${version_pcre}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    --enable-jit \
    --enable-pcre16 \
    --enable-pcre32 \
    --enable-utf \
    --enable-unicode-properties \
    &> /dev/null  
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_glib() {
  cd "${__DIR__}/build"
  rm -rf "glib-${version_glib}"*
  curl -sSOLf "http://ftp.gnome.org/pub/gnome/sources/glib/${version_glib%.*}/glib-${version_glib}.tar.xz"
  xz -d "glib-${version_glib}.tar.xz"
  tar xf "glib-${version_glib}.tar"
  cd "glib-${version_glib}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_libressl() {
  cd "${__DIR__}/build"
  rm -rf "libressl-${version_libressl}"*
  curl -sSOLf "http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${version_libressl}.tar.gz"
  tar xf "libressl-${version_libressl}.tar.gz"
  cd "libressl-${version_libressl}"
  ./configure \
    --prefix=/opt/libressl \
    --enable-nc \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_libicu() {
  cd "${__DIR__}/build"
  rm -rf "libicu-${version_libicu}"*
  curl -sSOLf "http://download.icu-project.org/files/icu4c/${version_libicu}/icu4c-${version_libicu/./_}-src.tgz"
  tar xf "icu4c-${version_libicu/./_}-src.tgz"
  cd icu/source
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    --disable-tests \
    --disable-samples \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_autoconf() {
  cd "${__DIR__}/build"
  rm -rf "autoconf-${version_autoconf}"*
  curl -sSOLf "http://ftp.gnu.org/gnu/autoconf/autoconf-${version_autoconf}.tar.gz"
  tar xf "autoconf-${version_autoconf}.tar.gz"
  cd "autoconf-${version_autoconf}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_lzma() {
  cd "${__DIR__}/build"
  rm -rf "lzma-${version_lzma}"*
  curl -sSOLf "http://tukaani.org/xz/xz-${version_lzma}.tar.gz"
  tar xf "xz-${version_lzma}.tar.gz"
  cd "xz-${version_lzma}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_yasm() {
  cd "${__DIR__}/build"
  rm -rf "yasm-${version_yasm}"*
  curl -sSOLf "http://www.tortall.net/projects/yasm/releases/yasm-${version_yasm}.tar.gz"
  tar xf "yasm-${version_yasm}.tar.gz"
  cd "yasm-${version_yasm}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_libjpeg() {
  cd "${__DIR__}/build"
  rm -rf "libjpeg-turbo-${version_libjpeg}"*
  curl -sSLfo "libjpeg-turbo-${version_libjpeg}.tar.gz" "https://sourceforge.net/projects/libjpeg-turbo/files/${version_libjpeg}/libjpeg-turbo-${version_libjpeg}.tar.gz/download"
  tar xf "libjpeg-turbo-${version_libjpeg}.tar.gz"
  cd "libjpeg-turbo-${version_libjpeg}"
  NASM=yasm ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    --with-java \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_libpng() {
  cd "${__DIR__}/build"
  rm -rf "libpng-${version_libpng}"*
  curl -sSLfo "libpng-${version_libpng}.tar.gz" "https://sourceforge.net/projects/libpng/files/libpng16/older-releases/${version_libpng}/libpng-${version_libpng}.tar.gz/download"
  tar xf "libpng-${version_libpng}.tar.gz"
  cd "libpng-${version_libpng}"
  cp scripts/makefile.darwin Makefile
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    --disable-dependency-tracking \
    --disable-silent-rules \
    &> /dev/null
  make &> /dev/null
  sudo make install &> /dev/null
}

build_zlib() {
  cd "${__DIR__}/build"
  rm -rf "zlib-${version_zlib}"*
  curl -sSOLf "http://zlib.net/zlib-${version_zlib}.tar.gz"
  tar xf "zlib-${version_zlib}.tar.gz"
  cd "zlib-${version_zlib}"
  ./configure \
    --prefix=/usr/local \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_libtiff() {
  cd "${__DIR__}/build"
  rm -rf "tiff-${version_libtiff}"*
  curl -sSOLf "ftp://download.osgeo.org/libtiff/tiff-${version_libtiff}.tar.gz"
  tar xf "tiff-${version_libtiff}.tar.gz"
  cd "tiff-${version_libtiff}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_libgif() {
  cd "${__DIR__}/build"
  rm -rf "giflib-${version_libgif}"*
  curl -sSLfo "giflib-${version_libgif}.tar.gz" "https://sourceforge.net/projects/giflib/files/giflib-${version_libgif}.tar.gz/download"
  tar xf "giflib-${version_libgif}.tar.gz"
  cd "giflib-${version_libgif}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_libvpx() {
  cd "${__DIR__}/build"
  rm -rf libvpx
  git clone --quiet https://chromium.googlesource.com/webm/libvpx
  cd libvpx
  ./configure \
    --prefix=/usr/local \
    --target=x86_64-darwin15-gcc \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_libwebp() {
  cd "${__DIR__}/build"
  rm -rf libwebp
  git clone --quiet https://chromium.googlesource.com/webm/libwebp
  cd libwebp
  ./autogen.sh &> /dev/null
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_pixman() {
  cd "${__DIR__}/build"
  rm -rf "pixman-${version_pixman}"*
  curl -sSOLf "https://www.cairographics.org/releases/pixman-${version_pixman}.tar.gz"
  tar xf "pixman-${version_pixman}.tar.gz"
  cd "pixman-${version_pixman}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_cairo() {
  cd "${__DIR__}/build"
  rm -rf "cairo-${version_cairo}"*
  curl -sSOLf "http://cairographics.org/snapshots/cairo-${version_cairo}.tar.xz"
  xz -d "cairo-${version_cairo}.tar.xz"
  tar xf "cairo-${version_cairo}.tar"
  cd "cairo-${version_cairo}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_pango() {
  cd "${__DIR__}/build"
  rm -rf "pango-${version_pango}"*
  curl -sSOLf "http://ftp.gnome.org/pub/GNOME/sources/pango/${version_pango%.*}/pango-${version_pango}.tar.xz"
  xz -d "pango-${version_pango}.tar.xz"
  tar xf "pango-${version_pango}.tar"
  cd "pango-${version_pango}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_libxml() {
  cd "${__DIR__}/build"
  rm -rf "libxml2-${version_libxml}"*
  curl -sSOLf "ftp://xmlsoft.org/libxml2/libxml2-${version_libxml}.tar.gz"
  tar xf "libxml2-${version_libxml}.tar.gz"
  cd "libxml2-${version_libxml}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_gdk_pixbuf() {
  cd "${__DIR__}/build"
  rm -rf "gdk-pixbuf-${version_gdk_pixbuf}"*
  curl -sSOLf "http://ftp.gnome.org/pub/GNOME/sources/gdk-pixbuf/${version_gdk_pixbuf%.*}/gdk-pixbuf-${version_gdk_pixbuf}.tar.xz"
  xz -d "gdk-pixbuf-${version_gdk_pixbuf}.tar.xz"
  tar xf "gdk-pixbuf-${version_gdk_pixbuf}.tar"
  cd "gdk-pixbuf-${version_gdk_pixbuf}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_libcroco() {
  cd "${__DIR__}/build"
  rm -rf "libcroco-${version_libcroco}"*
  curl -sSOLf "http://ftp.gnome.org/pub/GNOME/sources/libcroco/${version_libcroco%.*}/libcroco-${version_libcroco}.tar.xz"
  xz -d "libcroco-${version_libcroco}.tar.xz"
  tar xf "libcroco-${version_libcroco}.tar"
  cd "libcroco-${version_libcroco}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    --disable-Bsymbolic \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_librsvg() {
  cd "${__DIR__}/build"
  rm -rf "librsvg-${version_librsvg}"*
  #rm -f "${version_librsvg}.tar.gz"
  curl -sSOLf "https://download.gnome.org/sources/librsvg/${version_librsvg%.*}/librsvg-${version_librsvg}.tar.xz"
  xz -d "librsvg-${version_librsvg}.tar.xz"
  tar xf "librsvg-${version_librsvg}.tar"
  cd "librsvg-${version_librsvg}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    --disable-Bsymbolic \
    --enable-introspection=no \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_freetype() {
  cd "${__DIR__}/build"
  rm -rf "freetype-${version_freetype}"*
  curl -sSOLf "http://download.savannah.gnu.org/releases/freetype/freetype-${version_freetype}.tar.gz"
  tar xf "freetype-${version_freetype}.tar.gz"
  cd "freetype-${version_freetype}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_gettext() {
  cd "${__DIR__}/build"
  rm -rf "gettext-${version_gettext}"*
  curl -sSOLf "http://ftp.gnu.org/pub/gnu/gettext/gettext-${version_gettext}.tar.gz"
  tar xf "gettext-${version_gettext}.tar.gz"
  cd "gettext-${version_gettext}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_libmcrypt() {
  cd "${__DIR__}/build"
  rm -rf "libmcrypt-${version_libmcrypt}"*
  curl -sSLfo "libmcrypt-${version_libmcrypt}.tar.gz" "https://sourceforge.net/projects/mcrypt/files/Libmcrypt/${version_libmcrypt}/libmcrypt-${version_libmcrypt}.tar.gz/download"
  tar xf "libmcrypt-${version_libmcrypt}.tar.gz"
  cd "libmcrypt-${version_libmcrypt}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_libzip() {
  cd "${__DIR__}/build"
  rm -rf "libzip-${version_libzip}"*
  curl -sSOLf "http://www.nih.at/libzip/libzip-${version_libzip}.tar.gz"
  tar xf "libzip-${version_libzip}.tar.gz"
  cd "libzip-${version_libzip}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
  chmod +x lib/make_zipconf.sh
  sudo lib/make_zipconf.sh ./config.h /usr/local/include/zipconf.h
}

build_apr() {
  cd "${__DIR__}/build"
  rm -rf "apr-${version_apr}"*
  curl -sSOLf "http://apache.saix.net/apr/apr-${version_apr}.tar.gz"
  tar xf "apr-${version_apr}.tar.gz"
  cd "apr-${version_apr}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
  sudo mkdir -p /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.12.xctoolchain/usr/local/bin/
  sudo ln -sf /usr/local/bin/apr-1-config /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.12.xctoolchain/usr/local/bin/
}

build_apr_util() {
  cd "${__DIR__}/build"
  rm -rf "apr-util-${version_apr_util}"*
  curl -sSOLf "http://apache.saix.net/apr/apr-util-${version_apr_util}.tar.gz"
  tar xf "apr-util-${version_apr_util}.tar.gz"
  cd "apr-util-${version_apr_util}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    --with-apr=/usr/local \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
  sudo mkdir -p /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.12.xctoolchain/usr/local/bin/
  sudo ln -sf /usr/local/bin/apu-1-config /Applications/Xcode.app/Contents/Developer/Toolchains/OSX10.12.xctoolchain/usr/local/bin/
}

build_php_ext_igbinary() {
  cd "${__DIR__}/build"
  rm -rf "igbinary-${version_php_ext_igbinary}"*
  curl -sSOLf "http://pecl.php.net/get/igbinary-${version_php_ext_igbinary}.tgz"
  tar xf "igbinary-${version_php_ext_igbinary}.tgz"
  cd "igbinary-${version_php_ext_igbinary}"
  phpize
  ./configure > /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_php_ext_apcu() {
  cd "${__DIR__}/build"
  rm -rf "apcu-${version_php_ext_apcu}"*
  curl -sSOLf "http://pecl.php.net/get/apcu-${version_php_ext_apcu}.tgz"
  tar xf "apcu-${version_php_ext_apcu}.tgz"
  cd "apcu-${version_php_ext_apcu}"
  phpize
  ./configure > /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_php_ext_memcached() {
  cd "${__DIR__}/build"
  rm -rf "libmemcached-1.0.18"*
  curl -sSOLf https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
  tar xf libmemcached-1.0.18.tar.gz
  cd libmemcached-1.0.18
  curl -sSOLf https://launchpadlibrarian.net/192981027/libmemcached-1.0.18_osx-fix.diff
  patch -p1 < libmemcached-1.0.18_osx-fix.diff
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    --enable-libmemcachedprotocol \
    --disable-sasl \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null

  cd ..
  rm -rf "memcached-${version_php_ext_memcached}"*
  curl -sSOLf "http://pecl.php.net/get/memcached-${version_php_ext_memcached}.tgz"
  tar xf "memcached-${version_php_ext_memcached}.tgz"
  cd "memcached-${version_php_ext_memcached}"
  phpize
  ./configure \
    --enable-memcached-igbinary \
    --disable-memcached-sasl \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_php_ext_redis() {
  cd "${__DIR__}/build"
  rm -rf "redis-${version_php_ext_redis}"*
  curl -sSOLf "http://pecl.php.net/get/redis-${version_php_ext_redis}.tgz"
  tar xf "redis-${version_php_ext_redis}.tgz"
  cd "redis-${version_php_ext_redis}"
  phpize
  ./configure \
    --enable-redis-igbinary \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_php_ext_phpiredis() {
  cd "${__DIR__}/build"
  rm -rf "hiredis-0.13.3"
  rm -f "v0.13.3.tar.gz"
  curl -sSOLf "https://github.com/redis/hiredis/archive/v0.13.3.tar.gz"
  tar xf "v0.13.3.tar.gz"
  cd "hiredis-0.13.3"
  make -j4 &> /dev/null
  sudo make install &> /dev/null

  cd ..
  rm -rf "phpiredis-${version_php_ext_phpiredis}"*
  curl -sSOLf "https://github.com/nrk/phpiredis/archive/v${version_php_ext_phpiredis}.tar.gz"
  tar xf "v${version_php_ext_phpiredis}.tar.gz"
  cd "phpiredis-${version_php_ext_phpiredis}"
  phpize
  ./configure > /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_php_ext_xdebug() {
  cd "${__DIR__}/build"
  rm -rf "xdebug-${version_php_ext_xdebug}"*
  curl -sSOLf "http://pecl.php.net/get/xdebug-${version_php_ext_xdebug}.tgz"
  tar xf "xdebug-${version_php_ext_xdebug}.tgz"
  cd "xdebug-${version_php_ext_xdebug}"
  phpize
  ./configure > /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_imagemagick() {
  cd "${__DIR__}/build"
  rm -rf "ImageMagick-${version_imagemagick}"*
  curl -sSOLf "http://www.imagemagick.org/download/releases/ImageMagick-${version_imagemagick}.tar.gz"
  tar xf "ImageMagick-${version_imagemagick}.tar.gz"
  cd "ImageMagick-${version_imagemagick}"
  ./configure \
    --prefix=/usr/local \
    --sysconfdir=/private/etc \
    --localstatedir=/var \
    --enable-shared \
    --disable-static \
    --with-modules \
    --with-rsvg=yes \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

build_php_ext_imagick() {
  cd "${__DIR__}/build"
  rm -rf "imagick-${version_php_ext_imagick}"*
  curl -sSOLf "http://pecl.php.net/get/imagick-${version_php_ext_imagick}.tgz"
  tar xf "imagick-${version_php_ext_imagick}.tgz"
  cd "imagick-${version_php_ext_imagick}"
  phpize
  ./configure > /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

mkdir -p "${__DIR__}/build"

#
# required libs and software
#
# curl https://sh.rustup.rs -sSf | sh

if [[ -z "${SKIP_DEPS}" ]]; then
  if ! command_exists "pkg-config" || [[ "$(pkg-config --version)" != "${version_pkg_config}" ]]; then
    builder pkg_config
  fi

  if ! command_exists "automake" || ! automake --version | grep -qF "automake (GNU automake) ${version_automake}"; then
    builder automake
  fi

  if ! command_exists "autoconf" || ! autoconf --version | grep -qF "autoconf (GNU Autoconf) ${version_autoconf}"; then
    builder autoconf
  fi

  if ! command_exists "xz" || ! xz --version | grep -qF "xz (XZ Utils) ${version_lzma}"; then
    builder lzma
  fi

  builder libtool libffi pcre glib

  if [[ ! -f "/opt/libressl/bin/openssl" ]] || ! /opt/libressl/bin/openssl version | grep -qF "LibreSSL ${version_libressl}"; then
    builder libressl
  fi

  builder libicu yasm libjpeg zlib libpng libtiff libgif libvpx libwebp pixman

  if ! command_exists "cairo-trace" || ! cairo-trace --version | grep -qF "cairo-trace, version ${version_cairo}."; then
    builder cairo
  fi

  if ! command_exists "pango-view" || ! pango-view --version | grep -qF "pango-view (pango) ${version_pango}"; then
    builder pango
  fi

  builder libxml gdk_pixbuf libcroco librsvg freetype

  if ! command_exists "gettext" || ! gettext --version | grep -qF "gettext (GNU gettext-runtime) ${version_gettext}"; then
    builder gettext
  fi

  builder libmcrypt libzip

  if ! command_exists "apr-1-config" || [[ "$(apr-1-config --version)" != "${version_apr}" ]]; then
    builder apr
  fi

  if ! command_exists "apu-1-config" || [[ "$(apu-1-config --version)" != "${version_apr_util}" ]]; then
    builder apr_util
  fi
fi

#
# php-cli
#

cd "${__DIR__}/build"
rm -rf "php-${version_php}"*
curl -sSLfo "php-${version_php}.tar.gz" "http://de2.php.net/get/php-${version_php}.tar.gz/from/this/mirror"
tar xf "php-${version_php}.tar.gz"
cd "php-${version_php}" || exit 1

if [[ -z "${SKIP_PHP_CLI}" ]]; then
  consolelog 'bulding php-cli...'
  ./configure \
    --prefix=/opt/php70 \
    --disable-cgi \
    --with-config-file-path=/private/etc/php70/cli \
    --with-config-file-scan-dir=/private/etc/php70/cli/conf.d \
    --with-libxml-dir=/usr/local \
    --with-openssl=/opt/libressl \
    --with-pcre-regex \
    --without-sqlite3 \
    --with-zlib \
    --enable-bcmath \
    --with-bz2 \
    --enable-calendar \
    --with-curl \
    --without-cdb \
    --enable-exif \
    --enable-ftp \
    --with-gd \
    --with-webp-dir \
    --with-jpeg-dir \
    --with-png-dir \
    --with-freetype-dir \
    --enable-gd-native-ttf \
    --enable-gd-jis-conv \
    --with-gettext \
    --with-mhash \
    --enable-intl \
    --enable-mbstring \
    --with-mcrypt \
    --with-mysqli \
    --with-pdo-mysql \
    --without-pdo-sqlite \
    --enable-soap \
    --enable-sockets \
    --with-xmlrpc \
    --with-iconv-dir \
    --with-xsl \
    --enable-zip \
    --with-libzip \
    --enable-zend-signals \
    --with-pear \
    --enable-pcntl \
    --with-libedit \
    --with-readline \
    --enable-shmop \
    --enable-sysvshm \
    --enable-sysvsem \
    --enable-sysvmsg \
    --with-pdo-dblib=/usr/local \
    &> /dev/null

  make -j4 &> /dev/null
  sudo make install &> /dev/null

  # postinstall
  sudo mkdir -p /private/etc/php70/cli/conf.d
  sudo ln -sf /opt/php70/bin/php /usr/local/bin/php
  sudo ln -sf /opt/php70/bin/phpize /usr/local/bin/phpize
  sudo ln -sf /opt/php70/bin/php-config /usr/local/bin/php-config
fi

if ! make clean &> /dev/null; then
  consolelog 'nothing to clean...'
fi

#
# php-apache
#
if [[ -z "${SKIP_PHP_FPM}" ]]; then
  consolelog 'bulding php-fpm...'
  ./configure \
    --prefix=/opt/php70 \
    --enable-fpm \
    --disable-cgi \
    --disable-cli \
    --with-config-file-path=/private/etc/php70/fpm \
    --with-config-file-scan-dir=/private/etc/php70/fpm/conf.d \
    --without-pear \
    --with-libxml-dir=/usr/local \
    --with-openssl=/opt/libressl \
    --with-pcre-regex \
    --without-sqlite3 \
    --with-zlib \
    --enable-bcmath \
    --with-bz2 \
    --enable-calendar \
    --with-curl \
    --without-cdb \
    --enable-exif \
    --enable-ftp \
    --with-gd \
    --with-webp-dir \
    --with-jpeg-dir \
    --with-png-dir \
    --with-freetype-dir \
    --enable-gd-native-ttf \
    --enable-gd-jis-conv \
    --with-gettext \
    --with-mhash \
    --enable-intl \
    --enable-mbstring \
    --with-mcrypt \
    --with-mysqli \
    --with-pdo-mysql \
    --without-pdo-sqlite \
    --enable-soap \
    --enable-sockets \
    --with-xmlrpc \
    --with-iconv-dir \
    --with-xsl \
    --enable-zip \
    --with-libzip \
    --enable-zend-signals \
    --with-pdo-dblib=/usr/local \
    &> /dev/null

  make -j4 &> /dev/null
  sudo make install &> /dev/null

  # postinstall
  sudo mkdir -p /private/etc/php70/fpm/conf.d
  sudo mkdir -p /private/etc/php70/fpm/pool.d
fi

#
# install php-extensions
#

if ! command_exists "identify" || ! identify --version | grep -qF "Version: ImageMagick ${version_imagemagick}"; then
  builder imagemagick
fi

builder php_ext_igbinary php_ext_apcu php_ext_memcached php_ext_redis php_ext_phpiredis php_ext_xdebug php_ext_imagick

#
# config
#

cat <<EOF | sudo tee /private/etc/php70/cli/php.ini > /dev/null
[PHP]
expose_php = Off

memory_limit = -1

display_errors = On
display_startup_errors = Off
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = On
track_errors = Off
html_errors = Off

error_reporting = E_ALL
log_errors = Off

request_order = "GP"
register_globals = Off
register_long_arrays = Off
register_argc_argv = Off
auto_globals_jit = On

include_path = ".:/usr/lib/php"

enable_dl = Off

file_uploads = On
upload_tmp_dir = /tmp/
upload_max_filesize = 100M
max_file_uploads = 20
post_max_size = 100M

allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 30

[Date]
date.timezone = UTC

[mail function]
mail.add_x_header = Off

[mysqlnd]
mysqlnd.collect_statistics = Off
mysqlnd.collect_memory_statistics = Off

[Session]
session.gc_maxlifetime = 2592000
session.serialize_handler = igbinary

; EXTENSION SECTION
extension = igbinary.so
extension = apcu.so
extension = imagick.so
extension = redis.so
extension = phpiredis.so
extension = memcached.so

apc.serializer = igbinary
apc.shm_size = 16M
EOF

cat <<EOF | sudo tee /private/etc/php70/fpm/php.ini  > /dev/null
[PHP]
open_basedir = Off

disable_functions = exec, show_source, system, shell_exec, passthru, popen, proc_open, proc_nice, symlink, dl

expose_php = Off

display_errors = Off
display_startup_errors = Off
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = On
track_errors = Off
html_errors = Off

log_errors = On
error_reporting = E_ALL

request_order = "GP"
register_globals = Off
register_long_arrays = Off
register_argc_argv = Off
auto_globals_jit = On

include_path = ".:/usr/lib/php:/usr/lib/php/Smarty"

enable_dl = Off

file_uploads = On
upload_tmp_dir = /tmp/
upload_max_filesize = 100M
max_file_uploads = 20
post_max_size = 100M

allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 30

output_buffering = 4096
zlib.output_compression = On
zlib.output_compression_level = 6

max_execution_time = 60
max_input_time = 60
memory_limit = 256M

; performance
realpath_cache_size = 384k
realpath_cache_ttl = 600

[Date]
date.timezone = UTC

[mail function]
mail.add_x_header = Off

[mysqlnd]
mysqlnd.collect_statistics = Off
mysqlnd.collect_memory_statistics = Off

[Session]
session.gc_maxlifetime = 2592000
session.serialize_handler = igbinary

; opcache
zend_extension = /opt/php70/lib/php/extensions/no-debug-non-zts-20151012/opcache.so
opcache.memory_consumption = 256
opcache.interned_strings_buffer = 16
opcache.max_accelerated_files = 16229
opcache.revalidate_freq = 20
opcache.fast_shutdown = 0
opcache.enable_cli = 1
opcache.use_cwd = 1

; extensions
extension = igbinary.so
extension = apcu.so
extension = imagick.so
extension = redis.so
extension = phpiredis.so
extension = memcached.so

apc.serializer = igbinary
apc.shm_size = 16M
EOF

cat <<EOF | sudo tee /private/etc/php70/fpm/fpm.conf > /dev/null
;;;;;;;;;;;;;;;;;;;;;
; FPM Configuration ;
;;;;;;;;;;;;;;;;;;;;;
[global]
pid = /private/var/run/php70-fpm.pid
error_log = /private/var/log/php70-fpm.log
log_level = warning
emergency_restart_threshold = 10
emergency_restart_interval = 1m
process_control_timeout = 10s
daemonize = yes
rlimit_files = 8192
rlimit_core = 0
;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ;
;;;;;;;;;;;;;;;;;;;;
include=/private/etc/php70/fpm/pool.d/*.conf
EOF

cat <<EOF | sudo tee /private/etc/php70/fpm/pool.d/default.conf > /dev/null
[default]
user = _www
group = _www
listen = 127.0.0.1:9100
pm = ondemand
pm.max_children = 1
pm.process_idle_timeout = 300s
request_terminate_timeout = 90s
chdir = /Library/WebServer/Documents
catch_workers_output = no
security.limit_extensions = .php
EOF

cat <<EOF | sudo tee /Library/LaunchDaemons/net.php.fpm-70.plist > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>net.php.fpm-70</string>
    <key>ProgramArguments</key>
    <array>
      <string>/opt/php70/sbin/php-fpm</string>
      <string>--nodaemonize</string>
      <string>--fpm-config</string>
      <string>/private/etc/php70/fpm/fpm.conf</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
  </dict>
</plist>
EOF

sudo launchctl unload -w /Library/LaunchDaemons/net.php.fpm-70.plist
sudo launchctl load -w /Library/LaunchDaemons/net.php.fpm-70.plist
sudo launchctl stop net.php.fpm-70
sudo launchctl start net.php.fpm-70

# cleanup
rm -rf "${__DIR__}/build"
