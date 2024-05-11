import 'package:flutter_test/flutter_test.dart';
import 'package:mini_game_view/mini_game_view.dart';
import 'package:mini_game_view/mini_game_view_platform_interface.dart';
import 'package:mini_game_view/mini_game_view_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMiniGameViewPlatform
    with MockPlatformInterfaceMixin
    implements MiniGameViewPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MiniGameViewPlatform initialPlatform = MiniGameViewPlatform.instance;

  test('$MethodChannelMiniGameView is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMiniGameView>());
  });

  test('getPlatformVersion', () async {
    // MiniGameView miniGameViewPlugin = MiniGameView();
    // MockMiniGameViewPlatform fakePlatform = MockMiniGameViewPlatform();
    // MiniGameViewPlatform.instance = fakePlatform;
    //
    // expect(await miniGameViewPlugin.getPlatformVersion(), '42');
  });
}
