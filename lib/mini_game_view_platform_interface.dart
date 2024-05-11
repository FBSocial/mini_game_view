import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mini_game_view_method_channel.dart';

abstract class MiniGameViewPlatform extends PlatformInterface {
  /// Constructs a MiniGameViewPlatform.
  MiniGameViewPlatform() : super(token: _token);

  static final Object _token = Object();

  static MiniGameViewPlatform _instance = MethodChannelMiniGameView();

  /// The default instance of [MiniGameViewPlatform] to use.
  ///
  /// Defaults to [MethodChannelMiniGameView].
  static MiniGameViewPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MiniGameViewPlatform] when
  /// they register themselves.
  static set instance(MiniGameViewPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> loadGameView(
      {required String roomId, required String gameId}) async {
    throw UnimplementedError('loadGameView() has not been implemented.');
  }
}
