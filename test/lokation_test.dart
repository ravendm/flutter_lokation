import 'package:flutter_test/flutter_test.dart';
import 'package:lokation/lokation.dart';
import 'package:lokation/lokation_method_channel.dart';
import 'package:lokation/lokation_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLokationPlatform with MockPlatformInterfaceMixin implements LokationPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LokationPlatform initialPlatform = LokationPlatform.instance;

  test('$MethodChannelLokation is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLokation>());
  });

  test('getPlatformVersion', () async {
    Lokation lokationPlugin = Lokation();
    MockLokationPlatform fakePlatform = MockLokationPlatform();
    LokationPlatform.instance = fakePlatform;

    expect(await lokationPlugin.getPlatformVersion(), '42');
  });
}
