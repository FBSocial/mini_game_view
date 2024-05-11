import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_game_view/mini_game_view_method_channel.dart';

void main() {
  MethodChannelMiniGameView platform = MethodChannelMiniGameView();
  const MethodChannel channel = MethodChannel('mini_game_view');

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
