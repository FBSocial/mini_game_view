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

  /// 获取正在游戏中的玩家userid
  Future<List<String>> getPlayingUserIds() async {
    final result = await _methodChannel.invokeMethod('playingUserIds');
    List<String> userIds = [];
    if (result is List) {
      userIds = result.whereType<String>().toList();
    }
    return userIds;
  }
}
