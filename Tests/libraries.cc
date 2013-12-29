#include <stdio.h>

#include <sqlite3.h>
#include <jpeglib.h>
#include <webp/encode.h>
#include <png.h>
#include <lcms2.h>
#include <google/protobuf/io/zero_copy_stream_impl_lite.h>
#include <libexif/exif-data.h>
#if !defined(ANDROID) && !defined(__ANDROID__)
#include <exiv2/exiv2.hpp>
#endif

#include "libraries.h"

using namespace google::protobuf::io;

void test_libraries() {
  // Test libsqlite3
  sqlite3_libversion();
  
  // Test libjpeg-turbo
  struct jpeg_compress_struct cinfo;
  jpeg_create_compress(&cinfo);
  jpeg_destroy_compress(&cinfo);
  
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
  
  // Test libprotobuf-lite
  ArrayInputStream* stream = new ArrayInputStream(NULL, 0);
  delete stream;
  
  // Test libexif
  ExifData* exif = exif_data_new();
  exif_data_unref(exif);
  
#if !defined(ANDROID) && !defined(__ANDROID__)
  // Test libexiv2
  Exiv2::ExifData* data = new Exiv2::ExifData();
  delete data;
#endif
}
