import 'package:latlong2/latlong.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'lokation_method_channel.dart';

abstract class LokationPlatform extends PlatformInterface {
  /// Constructs a LokationPlatform.
  LokationPlatform() : super(token: _token);

  static final Object _token = Object();

  static LokationPlatform _instance = MethodChannelLokation();

  /// The default instance of [LokationPlatform] to use.
  ///
  /// Defaults to [MethodChannelLokation].
  static LokationPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LokationPlatform] when
  /// they register themselves.
  static set instance(LokationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> startPositionUpdates() async {
    throw UnimplementedError();
  }

  Future<void> stopPositionUpdates() async {
    throw UnimplementedError();
  }

  Future<bool> isServiceEnabled() async {
    throw UnimplementedError();
  }

  Future<bool> checkPermission() async {
    throw UnimplementedError();
  }

  Future<bool> requestPermission() async {
    throw UnimplementedError();
  }

  Stream<LatLng> get lokationStream;

  Stream<bool> get serviceStream;
}
