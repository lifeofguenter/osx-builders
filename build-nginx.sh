#!/usr/bin/env bash
#
# build nginx from source on osx
#

# nginx version
version_nginx=1.11.10

# dependency versions
version_pcre=8.40
version_zlib=1.2.11
version_openssl=1.1.0e

__DIR__="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${__DIR__}/functions.shlib"

set -E
trap 'throw_exception' ERR

build_nginx() {
  cd "${__DIR__}/build"
  rm -rf "nginx-${version_nginx}"*
  rm -rf "pcre-${version_pcre}"*
  rm -rf "openssl-${version_openssl}"*
  rm -rf "zlib-${version_zlib}"*
  rm -rf "ngx_brotli"

  curl -sSOLf "http://nginx.org/download/nginx-${version_nginx}.tar.gz" &
  curl -sSOLf "http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${version_pcre}.tar.gz" &
  curl -sSOLf "https://www.openssl.org/source/openssl-${version_openssl}.tar.gz" &
  curl -sSOLf "http://zlib.net/zlib-${version_zlib}.tar.gz" &
  git clone --quiet https://github.com/google/ngx_brotli.git &
  wait

  tar xf "nginx-${version_nginx}.tar.gz" &
  tar xf "pcre-${version_pcre}.tar.gz" &
  tar xf "openssl-${version_openssl}.tar.gz" &
  tar xf "zlib-${version_zlib}.tar.gz" &
  wait

  cd ngx_brotli && git submodule update --quiet --init && cd ..

  cd "nginx-${version_nginx}"
  ./configure \
    --prefix=/usr/local/share/nginx \
    --sbin-path=/usr/local/sbin/nginx \
    --conf-path=/private/etc/nginx/nginx.conf \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --lock-path=/private/var/lock/nginx.lock \
    --pid-path=/private/run/nginx.pid \
    --http-client-body-temp-path=/var/local/cache/nginx/client \
    --http-proxy-temp-path=/var/local/cache/nginx/proxy \
    --http-fastcgi-temp-path=/var/local/cache/nginx/fastcgi \
    --http-uwsgi-temp-path=/var/local/cache/nginx/uwsgi \
    --http-scgi-temp-path=/var/local/cache/nginx/scgi \
    --with-pcre="../pcre-${version_pcre}" \
    --with-pcre-jit \
    --with-zlib="../zlib-${version_zlib}" \
    --with-zlib-asm=pentiumpro \
    --with-http_ssl_module \
    --with-openssl="../openssl-${version_openssl}" \
    --with-http_addition_module \
    --with-http_realip_module \
    --with-http_sub_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_stub_status_module \
    --with-threads \
    --with-http_v2_module \
    --with-ipv6 \
    --without-http_memcached_module \
    --add-module=../ngx_brotli \
    &> /dev/null
  make -j4 &> /dev/null
  sudo make install &> /dev/null
}

mkdir -p "${__DIR__}/build"

if [[ ! -f "/usr/local/sbin/nginx" ]] || ! "/usr/local/sbin/nginx" -V | grep -qF "nginx version: nginx/${version_nginx}"; then
  builder nginx
fi

# postinstall
sudo mkdir -p /etc/nginx
sudo mkdir -p /var/local/cache/nginx
sudo mkdir -p /etc/nginx/common
sudo mkdir -p /etc/nginx/vhosts

user="$(whoami)"
cat <<EOF | sudo tee /etc/nginx/nginx.conf > /dev/null
user ${user} _www;
error_log /var/log/nginx/error.log;
pid /private/run/nginx.pid;

pcre_jit on;

events {
}

http {
  include       mime.types;
  default_type  application/octet-stream;

  resolver 8.8.8.8 8.8.4.4 valid=600s;
  resolver_timeout 4s;

  # make usage of $https dynamic
  map \$https \$fcgi_https {
    on on;
  }

  # make usage of \$scheme dynamic
  map \$http_x_forwarded_proto \$the_scheme {
    default \$scheme;
    https https;
  }

  log_format multitenant '\$remote_addr \$remote_user - [\$time_local] \$http_host "\$request" \$status \$body_bytes_sent "\$http_referer" "\$http_user_agent"';

  # security
  server_tokens off;

  # performance
  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  access_log off;
  open_file_cache max=10000 inactive=30s;
  open_file_cache_valid 60s;
  open_file_cache_min_uses 2;
  open_file_cache_errors on;

  keepalive_requests 1024;
  keepalive_timeout 120;
  send_timeout 60s;
  client_body_timeout 60s;
  client_max_body_size 100M;
  reset_timedout_connection on;

  # vhosts
  include vhosts/*.conf;
}
EOF

cat <<'EOF' | sudo tee /etc/nginx/common/client-performance.conf > /dev/null
# static file compression
gzip on;
gzip_proxied any;
gzip_comp_level 6;
gzip_types
  text/richtext
  text/plain
  text/css
  text/x-script
  text/x-component
  text/x-java-source
  application/javascript
  application/x-javascript
  text/javascript
  text/js
  image/x-icon
  text/xml
  application/xml
  application/xml+rss
  application/json
  application/xhtml+xml
  font/ttf
  font/otf
  font/woff
  font/woff2
  image/svg+xml
  application/vnd.ms-fontobject
  application/ttf
  application/x-ttf
  application/otf
  application/x-otf
  application/truetype
  application/opentype
  application/x-opentype
  application/woff
  application/eot
  application/font
  application/font-woff
  application/font-woff2
  application/font-sfnt;
gzip_disable "msie6";
gzip_vary on;

# static file expire
location ~* \.(css|js|jpg|jpeg|gif|ico|png|bmp|pict|csv|doc|pdf|pls|ppt|tif|tiff|eps|ejs|swf|midi|mid|ttf|eot|woff|woff2|otf|svg|svgz|webp|docx|xlsx|xls|pptx|ps|class|jar)$ {
  expires 1y;
  add_header Cache-Control public;
}
EOF

cat <<'EOF' | sudo tee /etc/nginx/common/cloudflare.conf > /dev/null
set_real_ip_from 10.0.0.0/8;
set_real_ip_from 172.16.0.0/12;
set_real_ip_from 192.168.0.0/16;

# curl -sSf https://www.cloudflare.com/ips-v4 | sed -e 's/^\(.*\)$/  set_real_ip_from \1;/'
set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 104.16.0.0/12;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 131.0.72.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 173.245.48.0/20;
set_real_ip_from 188.114.96.0/20;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 199.27.128.0/21;

# curl -sSf https://www.cloudflare.com/ips-v6 | sed -e 's/^\(.*\)$/  set_real_ip_from \1;/'
set_real_ip_from 2400:cb00::/32;
set_real_ip_from 2405:8100::/32;
set_real_ip_from 2405:b500::/32;
set_real_ip_from 2606:4700::/32;
set_real_ip_from 2803:f800::/32;
set_real_ip_from 2c0f:f248::/32;
set_real_ip_from 2a06:98c0::/29;

real_ip_header X-Forwarded-For;
real_ip_recursive on;

if ($http_cf_visitor ~ '{"scheme":"https"}') {
  set $fcgi_https on;
  set $real_scheme https;
}
EOF

cat <<'EOF' | sudo tee /etc/nginx/common/drop.conf > /dev/null
location ~ /\.          { access_log off; log_not_found off; deny all; }
location ~ ~$           { access_log off; log_not_found off; deny all; }
EOF

cat <<'EOF' | sudo tee /etc/nginx/common/secure-ssl.conf > /dev/null
# See: https://cipherli.st/ & https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html

ssl on;
ssl_ciphers "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 5m;

ssl_stapling on;
ssl_stapling_verify on;

add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
add_header X-Content-Type-Options nosniff always;
EOF

cat <<'EOF' | sudo tee /etc/nginx/fastcgi.conf > /dev/null
fastcgi_param  HOSTNAME           $hostname;
fastcgi_param  SERVER_NAME        $host;

fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
fastcgi_param  QUERY_STRING       $query_string;
fastcgi_param  REQUEST_METHOD     $request_method;
fastcgi_param  CONTENT_TYPE       $content_type;
fastcgi_param  CONTENT_LENGTH     $content_length;

fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
fastcgi_param  PATH_INFO          $fastcgi_path_info;
fastcgi_param  PATH_TRANSLATED    $document_root$fastcgi_path_info;
fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
fastcgi_param  REQUEST_URI        $request_uri;
fastcgi_param  DOCUMENT_URI       $document_uri;
fastcgi_param  DOCUMENT_ROOT      $document_root;
fastcgi_param  SERVER_PROTOCOL    $server_protocol;
fastcgi_param  HTTPS              $fcgi_https if_not_empty;

fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;

fastcgi_param  REMOTE_ADDR        $remote_addr;
fastcgi_param  REMOTE_PORT        $remote_port;
fastcgi_param  SERVER_ADDR        $server_addr;
fastcgi_param  SERVER_PORT        $server_port;

# PHP only, required if PHP was built with --enable-force-cgi-redirect
fastcgi_param  REDIRECT_STATUS    200;
EOF

cat <<'EOF' | sudo tee /etc/nginx/mime.types > /dev/null
types {
  text/html                             html htm shtml;
  text/css                              css;
  text/xml                              xml;
  image/gif                             gif;
  image/jpeg                            jpeg jpg;
  application/javascript                js;
  application/atom+xml                  atom;
  application/rss+xml                   rss;

  text/mathml                           mml;
  text/plain                            txt log;
  text/vnd.sun.j2me.app-descriptor      jad;
  text/vnd.wap.wml                      wml;
  text/x-component                      htc;

  image/png                             png;
  image/tiff                            tif tiff;
  image/vnd.wap.wbmp                    wbmp;
  image/x-icon                          ico;
  image/x-jng                           jng;
  image/x-ms-bmp                        bmp;
  image/svg+xml                         svg svgz;
  image/webp                            webp;

  application/font-woff                 woff;
  font/woff2                            woff2;
  application/java-archive              jar war ear;
  application/json                      json;
  application/mac-binhex40              hqx;
  application/msword                    doc;
  application/pdf                       pdf;
  application/postscript                ps eps ai;
  application/rtf                       rtf;
  application/vnd.apple.mpegurl         m3u8;
  application/vnd.ms-excel              xls;
  application/vnd.ms-fontobject         eot;
  application/font-sfnt                 otf;
  application/vnd.ms-powerpoint         ppt;
  application/vnd.wap.wmlc              wmlc;
  application/vnd.google-earth.kml+xml  kml;
  application/vnd.google-earth.kmz      kmz;
  application/x-7z-compressed           7z;
  application/x-cocoa                   cco;
  application/x-java-archive-diff       jardiff;
  application/x-java-jnlp-file          jnlp;
  application/x-makeself                run;
  application/x-perl                    pl pm;
  application/x-pilot                   prc pdb;
  application/x-rar-compressed          rar;
  application/x-redhat-package-manager  rpm;
  application/x-sea                     sea;
  application/x-shockwave-flash         swf;
  application/x-stuffit                 sit;
  application/x-tcl                     tcl tk;
  application/x-x509-ca-cert            der pem crt;
  application/x-xpinstall               xpi;
  application/xhtml+xml                 xhtml;
  application/xspf+xml                  xspf;
  application/zip                       zip;

  application/octet-stream              bin exe dll;
  application/octet-stream              deb;
  application/octet-stream              dmg;
  application/octet-stream              iso img;
  application/octet-stream              msi msp msm;

  application/vnd.openxmlformats-officedocument.wordprocessingml.document    docx;
  application/vnd.openxmlformats-officedocument.spreadsheetml.sheet          xlsx;
  application/vnd.openxmlformats-officedocument.presentationml.presentation  pptx;

  audio/midi                            mid midi kar;
  audio/mpeg                            mp3;
  audio/ogg                             ogg;
  audio/x-m4a                           m4a;
  audio/x-realaudio                     ra;

  video/3gpp                            3gpp 3gp;
  video/mp2t                            ts;
  video/mp4                             mp4;
  video/mpeg                            mpeg mpg;
  video/quicktime                       mov;
  video/webm                            webm;
  video/x-flv                           flv;
  video/x-m4v                           m4v;
  video/x-mng                           mng;
  video/x-ms-asf                        asx asf;
  video/x-ms-wmv                        wmv;
  video/x-msvideo                       avi;
}
EOF

cat <<'EOF' | sudo tee /etc/nginx/vhosts/default.conf > /dev/null
server {
  listen 80 default_server;
  root /Library/WebServer/Documents;

  # enable php
  location ~ [^/]\.php(/|$) {
    fastcgi_split_path_info ^(.+\.php)(.*)$;
    try_files $uri =404;
    fastcgi_pass 127.0.0.1:9100;
    fastcgi_index index.php;
    include fastcgi.conf;
  }

  include common/drop.conf;
}
EOF

sudo cp -n /Library/WebServer/Documents/index.html.en /Library/WebServer/Documents/index.html
sudo /usr/local/sbin/nginx -t

cat <<EOF | sudo tee /Library/LaunchDaemons/org.nginx.plist > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>org.nginx</string>
    <key>ProgramArguments</key>
    <array>
      <string>/usr/local/sbin/nginx</string>
      <string>-g</string>
      <string>daemon off;</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
  </dict>
</plist>
EOF

sudo launchctl unload -w /Library/LaunchDaemons/org.nginx.plist
sudo launchctl load -w /Library/LaunchDaemons/org.nginx.plist
sudo launchctl stop org.nginx
sudo launchctl start org.nginx

# cleanup
rm -rf "${__DIR__}/build"
