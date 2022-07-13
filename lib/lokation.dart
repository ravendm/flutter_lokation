import 'package:latlong2/latlong.dart';

import 'lokation_platform_interface.dart';

class Lokation {
  Lokation._();

  static Future<void> startPositionUpdates() {
    return LokationPlatform.instance.startPositionUpdates();
  }

  static Future<void> stopPositionUpdates() {
    return LokationPlatform.instance.stopPositionUpdates();
  }

  static Future<bool> checkPermission() => LokationPlatform.instance.checkPermission();

  static Future<bool> requestPermission() => LokationPlatform.instance.requestPermission();

  static Future<bool> get isServiceEnabled => LokationPlatform.instance.isServiceEnabled();

  static Stream<LatLng> get locationStream => LokationPlatform.instance.lokationStream;

  static Stream<bool> get serviceStream => LokationPlatform.instance.serviceStream;
}
