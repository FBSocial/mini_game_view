import 'package:flutter/services.dart';
import 'package:mini_game_view/mini_game_view_method_channel.dart';

class MiniGameController {
  late MethodChannel _methodChannel;

  MiniGameController() {
    _methodChannel = MiniGameViewChannel.instance.methodChannel;
  }

  /// 数字炸弹命中关键字
  void hitBomb(String msg) {
    _methodChannel.invokeMethod('hitBomb', msg);
  }
}
