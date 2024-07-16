import 'package:flutter/services.dart';
import 'package:mini_game_view/mini_game_info.dart';
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

  /// 获取指定用户的头像坐标及大小
  Future<MiniGamePlayerPosition?> getPlayerPosition(String playerId) async {
    final positionMap =
        await _methodChannel.invokeMethod('playerIconPosition', playerId);
    if (positionMap is! Map) return null;
    return MiniGamePlayerPosition(
      userId: playerId,
      x: positionMap['x'],
      y: positionMap['y'],
      width: positionMap['width'],
      height: positionMap['height'],
    );
  }
}
