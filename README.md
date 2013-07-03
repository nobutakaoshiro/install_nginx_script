install_nginx_script for OS X
=============================

## 概要
OS X に Nginx をインストールするスクリプトです。
Nginx のソースコードをコンパイルしてインストールします。


## メモ
* OS X 10.8 Mountain Lion で動作確認
* ソースコードから Nginx をインストール
* /usr/local/src にダウンロードしたソースコードを保存
* nginx-upload-module と nginx-upload-progress-module 入り
* 要 Xcode Command Line Tools
* 要 OpenSSL 1.0.0 以上
    * OS X 10.8 標準の OpenSSL は 0.9.8x のため、OpenSSL を別にインストールする必要がある
    * homebrew でインストールすると楽
    
```bash
$ brew install openssl
```

