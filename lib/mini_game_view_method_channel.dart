import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MiniGameViewChannel extends PlatformInterface {
  MiniGameViewChannel() : super(token: _token);

  static final Object _token = Object();

  static MiniGameViewChannel _instance = MiniGameViewChannel();

  static MiniGameViewChannel get instance => _instance;

  static set instance(MiniGameViewChannel instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  final methodChannel = const MethodChannel('mini_game_view/method');
  final eventChannel = const EventChannel('mini_game_view/event');
}
