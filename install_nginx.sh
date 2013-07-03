#!/bin/bash -x
#
# Nginx Install Script for OS X
#
# Author: Nobutaka OSHIRO
# Version: 0.1.0
#

####################################################
# Nginx インストールディレクトリ
PREFIX=/usr/local/nginx

# Nginx やその他ソース置き場
SRC_DIR=/usr/local/src

# ソースディレクトリのユーザとグループ
USER=`whoami`
GROUP=staff

# Nginx のユーザ/グループ (nginx.conf で指定しなかった場合のデフォルト設定)
NGINX_USER=_www
NGINX_GROUP=daemon

# Nginx のバージョン
NGINX_VERSION=1.4.1

# Nginx のコンパイルで必要なライブラリ
PCRE_VERSION=8.32

# OpenSSL のバージョン
# OPENSSL_VERSION=1.0.1e

# ログディレクトリ
ACCESS_LOG_PATH=/var/log/nginx/access.log
ERROR_LOG_PATH=/var/log/nginx/error.log

# CC オプション
CC_OPT="-I/usr/local/opt/openssl/include"

# LD オプション
LD_OPT="-L/usr/local/opt/openssl/lib"

####################################################

# ソースディレクトリの作成
sudo mkdir -p $SRC_DIR
sudo chown -R $USER:$GROUP $SRC_DIR

# Nginx のダウンロード
cd $SRC_DIR
if [ ! -e nginx-$NGINX_VERSION.tar.gz ]; then
  curl -O http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
  tar xzvf nginx-$NGINX_VERSION.tar.gz
fi

## nginx-upload-module
if [ ! -e nginx-upload-module ]; then
  git clone https://github.com/vkholodkov/nginx-upload-module.git
  cd nginx-upload-module
  ### nginx-upload-module ver.2.2 に切替
  git checkout -b 2.2 refs/tags/2.2.0
  ### nginx-upload-module のパッチのダウンロードと適用
  curl -O http://portage.perestoroniny.ru/www-servers/nginx/files/nginx-1.3.9_upload_module.patch
  patch < nginx-1.3.9_upload_module.patch
  cd ../
fi

## nginx-upload-progress-module
if [ ! -e nginx-upload-progress-module ]; then
  git clone https://github.com/masterzen/nginx-upload-progress-module.git
fi

## OpenSSL
#if [ ! -e openssl-$OPENSSL_VERSION.tar.gz ]; then
#  curl -O http://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
#  tar xzvf openssl-$OPENSSL_VERSION.tar.gz
#  cd openssl-$OPENSSL_VERSION
#  #./Configure darwin64-x86_64-cc --prefix=/usr/local
#  ./Configure darwin64-x86_64-cc --prefix=/opt/openssl
#  make
#  ## OpenSSL のインストール
#  sudo make install
#  cd ..
#fi

### nginx はビルド時に PCRE ライブラリを利用するので併せて PCRE ライブラリもダウンロードしておく
if [ ! -e pcre-$PCRE_VERSION.tar.gz ]; then
  curl -O ftp://anonymous@ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$PCRE_VERSION.tar.gz
  tar xzvf pcre-$PCRE_VERSION.tar.gz

  ### PCRE ライブラリをインストールする
  cd pcre-$PCRE_VERSION
  ./configure
  make
  sudo make install
  cd ..
fi

### nginx をビルドする
cd $SRC_DIR/nginx-$NGINX_VERSION

./configure --prefix=${PREFIX} \
            --user=${NGINX_USER} \
            --group=${NGINX_GROUP} \
            --with-http_ssl_module \
            --with-http_spdy_module \
            --pid-path=/var/run/nginx.pid \
            --http-log-path=${ACCESS_LOG_PATH} \
            --error-log-path=${ERROR_LOG_PATH} \
            --add-module=${SRC_DIR}/nginx-upload-module \
            --add-module=${SRC_DIR}/nginx-upload-progress-module \
            --with-cc-opt=${CC_OPT} \
            --with-ld-opt=${LD_OPT}

make

### Nginx のインストール
#sudo make install
