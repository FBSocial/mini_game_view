import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mini_game_view/mini_game_info.dart';
import 'package:mini_game_view/mini_game_view_method_channel.dart';

const _onGameContainerCreatedAction = 'onGameContainerCreated';
const _onExpireCodeAction = 'onExpireCode';

class MiniGameController {
  final MiniGameInfo info;

  final MiniGameConfig config;

  final MiniGameViewPosition? position;

  final Future<String> Function() loginCodeCallback;

  late StreamSubscription _subscription;
  late MethodChannel _methodChannel;

  MiniGameController({
    required this.config,
    required this.info,
    required this.loginCodeCallback,
    this.position,
  }) {
    _methodChannel = MiniGameViewChannel.instance.methodChannel;
    _subscription = MiniGameViewChannel.instance.eventChannel
        .receiveBroadcastStream()
        .listen(_eventListener);
  }

  void _eventListener(dynamic event) {
    if (event is! Map) return;
    // eg. {'action': 'onGameLogin', 'data': {}}
    final action = event['action'];
    // final data = event['data'];
    if (action == _onGameContainerCreatedAction) {
      _onGameContainerCreated();
    } else if (action == _onExpireCodeAction) {
      _onExpireCode();
    }
  }

  /// PlatformView创建后加载GameView父容器，并通知flutter层获取SUD的login code
  /// 成功获取后立即开始加载游戏
  Future<void> _onGameContainerCreated() async {
    try {
      final loginCode = await loginCodeCallback.call();
      if (loginCode.isEmpty) return;
      await _methodChannel.invokeMethod('loginGame', loginCode);
    } catch (e) {
      debugPrint('_onGameContainerCreated, ${e.toString()}');
    }
  }

  /// 处理游戏code过期
  Future<void> _onExpireCode() async {
    try {
      final loginCode = await loginCodeCallback.call();
      await _methodChannel.invokeMethod('updateCode', loginCode);
    } catch (e) {
      debugPrint('_onGameContainerCreated, ${e.toString()}');
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
