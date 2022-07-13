import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokation/lokation_method_channel.dart';

void main() {
  MethodChannelLokation platform = MethodChannelLokation();
  const MethodChannel channel = MethodChannel('lokation');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
