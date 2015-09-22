#include <stdio.h>

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

using namespace google::protobuf::io;

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
  
  // We're done!
  printf("OK\n");
  return 0;
}
