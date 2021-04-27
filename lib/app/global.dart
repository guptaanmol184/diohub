import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_hub/routes/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class Global {
  static final AppRouter customRouter = AppRouter();
  static final BuildContext currentContext =
      customRouter.navigatorKey.currentContext!;
  static const String apiBaseURL = 'https://api.github.com';
  static final Logger log = Logger();
  static String? _directoryPath;
  static String? get directoryPath => _directoryPath;
  static HiveCacheStore? _cacheStore;
  static HiveCacheStore get cacheStore => _cacheStore!;

  static Future setupAppCache() async {
    await getApplicationDocumentsDirectory()
        .then((value) => _directoryPath = value.path);
    _cacheStore = HiveCacheStore(_directoryPath);
  }
}
