#include <stdio.h>
#include <pthread.h>

#include <sqlite3.h>
#include <webp/encode.h>
#include <png.h>
#include <lcms2.h>
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wshorten-64-to-32"
#include <google/protobuf/io/zero_copy_stream_impl_lite.h>
#pragma clang diagnostic pop
#include <libexif/exif-data.h>
#include <exiv2/exiv2.hpp>
#include <libssh2.h>
#include <curl/curl.h>
#include <openssl/opensslconf.h>
#include <openssl/crypto.h>
#include <openssl/bio.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/conf.h>
#include <openssl/evp.h>
#include <ffi.h>
#include <unicode/regex.h>
#include <mbedtls/ssl.h>

using namespace google::protobuf::io;

static pthread_mutex_t* _openSSLMutexes;

static void _OpenSSLLockingCallback(int mode, int n, const char* file, int line) {
	if (mode & CRYPTO_LOCK) {
    pthread_mutex_lock(&_openSSLMutexes[n]);
	} else {
    pthread_mutex_unlock(&_openSSLMutexes[n]);
	}
}

int main(int argc, const char* argv[]) {
  // Test libsqlite3
  sqlite3_libversion();
  if (!sqlite3_compileoption_used("THREADSAFE=2") || !sqlite3_compileoption_used("ENABLE_FTS3") || !sqlite3_compileoption_used("ENABLE_FTS3_PARENTHESIS")) {
    abort();
  }
  
  // Test libwebp
  WebPConfig config;
  WebPConfigInit(&config);
  
  // Test libpng
  png_structp png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  png_destroy_write_struct(&png_ptr, NULL);
  
  // Test liblcms2
  cmsHPROFILE input_profile = cmsOpenProfileFromMem(NULL, 0);
  if (input_profile) {
    cmsCloseProfile(input_profile);
  }
  
  // Test libprotobuf
  ArrayInputStream* stream = new ArrayInputStream(NULL, 0);
  delete stream;
  
  // Test libexif
  ExifData* exif = exif_data_new();
  exif_data_unref(exif);
  
  // Test libexiv2
  Exiv2::ExifData* data = new Exiv2::ExifData();
  delete data;
  
  // Test libssh2
  libssh2_version(0);
  
  // Test libcurl
  curl_version_info(CURLVERSION_NOW);
  
  // Test libcrypto / libssl
#ifndef OPENSSL_THREADS
#error OpenSSL built without threads
#endif
  int count = CRYPTO_num_locks();
  _openSSLMutexes = (pthread_mutex_t*)calloc(count, sizeof(pthread_mutex_t));
  for (int i = 0; i < count; ++i) {
    if (pthread_mutex_init(&_openSSLMutexes[i], NULL)) {
      abort();
    }
  }
  CRYPTO_set_locking_callback(_OpenSSLLockingCallback);
  ERR_load_crypto_strings();
  ERR_load_BIO_strings();
  SSL_load_error_strings();
  OpenSSL_add_all_algorithms();
  OPENSSL_config(NULL);

  // Test libffi (n-dic)
  {
    ffi_cif cif;
    ffi_type* args[1];
    void* values[1];
    const char* s;
    ffi_arg rc;

    args[0] = &ffi_type_pointer;
    values[0] = &s;

    if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 1, &ffi_type_sint, args) == FFI_OK) {
      s = "Hello World!";
      ffi_call(&cif, (void (*)())puts, &rc, values);

      s = "This is cool!";
      ffi_call(&cif, (void (*)())puts, &rc, values);
    }
  }

  // Test libffi (variadic)
  {
    const char* format = "TEST = %f / %i / %s\n";
    double value1 = 3.14159265359;
    int value2 = 42;
    const char* value3 = "bonjour";
    ffi_type* args[] = {&ffi_type_pointer, &ffi_type_double, &ffi_type_sint32, &ffi_type_pointer};
    void* values[] = {&format, &value1, &value2, &value3};
    ffi_cif cif;
    if (ffi_prep_cif_var(&cif, FFI_DEFAULT_ABI, 1, 4, &ffi_type_sint, args) == FFI_OK) {
      ffi_arg rc;
      ffi_call(&cif, (void (*)())printf, &rc, values);
    }
  }

  // Test libicu
  {
    UErrorCode status = U_ZERO_ERROR;
    RegexMatcher matcher("abc+", UREGEX_CASE_INSENSITIVE, status);
    auto utf8 = UnicodeString::fromUTF8("Find the abc in this string");
    matcher.reset(utf8);
    matcher.find();
  }

  // Test libmbedtls
  {
    mbedtls_ssl_context ssl;
    mbedtls_ssl_init(&ssl);
  }

  // We're done!
#ifdef __LP64__
  printf("OK 64\n");
#else
  printf("OK 32\n");
#endif
  return 0;
}
