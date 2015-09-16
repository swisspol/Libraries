Overview
========

This repository contains various open source libraries precompiled as static libraries and ready-to-use for Mac OS X (x86_64), iPhone Simulator (i386, x86_64) and iPhone OS (armv7, arm64) with bitcode. The build scripts are also provided.

* [libcurl](http://curl.haxx.se/libcurl/) (with everything disabled except HTTP, SSL and proxy)
* [libexif](http://libexif.sourceforge.net/)
* [libexiv2](http://www.exiv2.org/)
* [libexpat](http://expat.sourceforge.net/)
* [liblcms2](http://www.littlecms.com/)
* [libpng](http://www.libpng.org/pub/png/libpng.html)
* [libprotobuf](https://developers.google.com/protocol-buffers/)
* [libsqlite3](http://www.sqlite.org/) (with FTS enabled and default threading mode set to multi-threaded i.e. SQLITE_THREADSAFE=2)
* [libssh2](http://www.libssh2.org/)
* [libwebp](https://developers.google.com/speed/webp/)
* [openssl](https://www.openssl.org/) (built using https://github.com/x2on/OpenSSL-for-iPhone)

Build Environment
=================

* OS X 10.10.5
* Xcode 7.0
* OS X SDK 11.0 (minimum deployment version 10.8)
* iOS SDK 9.0 (minimum deployment version 8.0)

Using the Libraries
===================

You need to configure the build settings to properly reference the headers from the "include" directories and library files from the "lib" directories.

See the included Tests Xcode project for an example.
