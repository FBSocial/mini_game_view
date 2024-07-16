/// 小游戏配置
class MiniGameConfig {
  final String appId;
  final String appKey;
  final bool isTestEnv;

  MiniGameConfig({
    required this.appId,
    required this.appKey,
    required this.isTestEnv,
  });
}

/// 小游戏房间信息
class MiniGameInfo {
  /// 用户id
  final String userId;

  /// 游戏id
  final String gameId;

  /// 房间id
  final String roomId;

  MiniGameInfo({
    required this.userId,
    required this.gameId,
    required this.roomId,
  });
}

class MiniGameSetting {
  final bool hideGameBg;
  final bool hideLoadingGameBg;
  final ViewPosition? position;

  MiniGameSetting({
    this.hideGameBg = false,
    this.hideLoadingGameBg = false,
    this.position,
  });
}

class ViewPosition {
  final int top;
  final int left;
  final int right;
  final int bottom;

  ViewPosition({
    this.top = 0,
    this.left = 0,
    this.right = 0,
    this.bottom = 0,
  });
}

class MiniGamePlayerPosition {
  final String userId;
  final double x;
  final double y;
  final double width;
  final double height;

  MiniGamePlayerPosition({
    required this.userId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}
