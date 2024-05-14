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

class MiniGameViewPosition {
  final int top;
  final int left;
  final int right;
  final int bottom;

  MiniGameViewPosition({
    this.top = 0,
    this.left = 0,
    this.right = 0,
    this.bottom = 0,
  });
}
