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
    final x = positionMap['x'];
    final y = positionMap['y'];
    final width = positionMap['width'];
    final height = positionMap['height'];
    return MiniGamePlayerPosition(
      userId: playerId,
      x: (x is int) ? x.toDouble() : x,
      y: (y is int) ? y.toDouble() : y,
      width: (width is int) ? width.toDouble() : width,
      height: (height is int) ? height.toDouble() : height,
    );
  }
}
