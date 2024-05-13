import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mini_game_view_platform_interface.dart';

/// An implementation of [MiniGameViewPlatform] that uses method channels.
class MethodChannelMiniGameView extends MiniGameViewPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mini_game_view');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> loadGameView() async {
    await methodChannel.invokeMethod('loadGameView');
  }
}
