import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Codec;

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class NetworkCacheImage extends ImageProvider<NetworkCacheImage> {

  /// The URL from which the image will be fetched.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  final Map<String, String> headers;

  const NetworkCacheImage(this.url, {this.scale = 1.0, this.headers})
      : assert(url != null),
        assert(scale != null);

  @override
  ImageStreamCompleter load(NetworkCacheImage key) {
    return null;
  }

  @override
  bool operator ==(other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    final NetworkCacheImage typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(url, scale);

  @override
  String toString() {
    return '$runtimeType("$url", scale: $scale)';
  }
}