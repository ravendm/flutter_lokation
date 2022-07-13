import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import 'lokation_platform_interface.dart';

/// An implementation of [LokationPlatform] that uses method channels.
class MethodChannelLokation extends LokationPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('lokation_method_channel');

  @visibleForTesting
  final lokationEventChannel = const EventChannel('lokation_position_event_channel');

  @visibleForTesting
  final serviceEventChannel = const EventChannel('lokation_service_event_channel');

  late Stream lokationEventStream;

  late Stream serviceEventStream;

  final lokationStreamController = StreamController<LatLng>.broadcast();
  final serviceStreamController = StreamController<bool>.broadcast();

  @override
  Stream<LatLng> get lokationStream => lokationStreamController.stream;

  @override
  Stream<bool> get serviceStream => serviceStreamController.stream;

  MethodChannelLokation() {
    lokationEventStream = lokationEventChannel.receiveBroadcastStream();
    lokationEventStream.listen((event) {
      lokationStreamController.add(LatLng(event['latitude'] as double, event['longitude'] as double));
    });
    serviceEventStream = serviceEventChannel.receiveBroadcastStream();
    serviceEventStream.listen((event) {
      serviceStreamController.add(event);
    });
  }

  @override
  Future<void> startPositionUpdates() => methodChannel.invokeMethod('startPositionUpdates');

  @override
  Future<void> stopPositionUpdates() => methodChannel.invokeMethod('stopPositionUpdates');

  @override
  Future<bool> isServiceEnabled() => methodChannel.invokeMethod('isServiceEnabled').then((value) => value as bool);

  @override
  Future<bool> requestPermission() => methodChannel.invokeMethod('requestPermission').then((value) => value as bool);

  @override
  Future<bool> checkPermission() => methodChannel.invokeMethod('checkPermission').then((value) => value as bool);
}
