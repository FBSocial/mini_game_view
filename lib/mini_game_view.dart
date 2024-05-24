import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mini_game_view/mini_game_controller.dart';
import 'package:mini_game_view/mini_game_info.dart';
import 'package:mini_game_view/mini_game_view_method_channel.dart';

const _onGameContainerCreatedAction = 'onGameContainerCreated';
const _onExpireCodeAction = 'onExpireCode';
const _onGameSettleCloseAction = 'onGameSettleClose';
const _onGameSettleAgainAction = 'onGameSettleAgain';

class MiniGameView extends StatefulWidget {
  final MiniGameInfo info;

  final MiniGameConfig config;

  final MiniGameSetting? setting;

  final Future<String> Function() onGameLoginCode;
  final Function()? onGameSettleAgain;
  final Function()? onGameSettleClose;
  final MiniGameController? controller;

  const MiniGameView({
    required this.config,
    required this.info,
    required this.onGameLoginCode,
    this.onGameSettleClose,
    this.onGameSettleAgain,
    this.setting,
    this.controller,
    super.key,
  });

  @override
  State<MiniGameView> createState() => _MiniGameViewState();
}

class _MiniGameViewState extends State<MiniGameView> {
  late StreamSubscription _subscription;
  late MethodChannel _methodChannel;
  MiniGameController? controller;

  @override
  void initState() {
    super.initState();
    controller =
        widget.controller == null ? widget.controller : MiniGameController();

    _methodChannel = MiniGameViewChannel.instance.methodChannel;
    _subscription = MiniGameViewChannel.instance.eventChannel
        .receiveBroadcastStream()
        .listen(_eventListener);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = 'mini-game-view-type';
    Map<String, dynamic> creationParams = <String, dynamic>{};

    final config = widget.config;
    creationParams['appId'] = config.appId;
    creationParams['appKey'] = config.appKey;
    creationParams['isTestEnv'] = config.isTestEnv;

    final info = widget.info;
    creationParams['roomId'] = info.roomId;
    creationParams['gameId'] = info.gameId;
    creationParams['userId'] = info.userId;

    final setting = widget.setting;
    final position = widget.setting?.position;

    creationParams['hideGameBg'] = setting?.hideGameBg ?? false;
    creationParams['hideLoadingGameBg'] = setting?.hideLoadingGameBg ?? false;
    creationParams['top'] = position?.top ?? 0;
    creationParams['left'] = position?.left ?? 0;
    creationParams['right'] = position?.right ?? 0;
    creationParams['bottom'] = position?.bottom ?? 0;

    if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (Platform.isAndroid) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () {
              params.onFocusChanged(true);
            },
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
      );
    }
    return const SizedBox.shrink();
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
    } else if (action == _onGameSettleCloseAction) {
      _onGameSettleClose();
    } else if (action == _onGameSettleAgainAction) {
      _onGameSettleAgain();
    }
  }

  /// PlatformView创建后加载GameView父容器，并通知flutter层获取SUD的login code
  /// 成功获取后立即开始加载游戏
  Future<void> _onGameContainerCreated() async {
    try {
      final loginCode = await widget.onGameLoginCode.call();
      if (loginCode.isEmpty) return;
      await _methodChannel.invokeMethod('loginGame', loginCode);
    } catch (e) {
      debugPrint('_onGameContainerCreated, ${e.toString()}');
    }
  }

  /// 处理游戏code过期
  Future<void> _onExpireCode() async {
    try {
      final loginCode = await widget.onGameLoginCode.call();
      await _methodChannel.invokeMethod('updateCode', loginCode);
    } catch (e) {
      debugPrint('_onGameContainerCreated, ${e.toString()}');
    }
  }

  void _onGameSettleClose() {
    widget.onGameSettleClose?.call();
  }

  void _onGameSettleAgain() {
    widget.onGameSettleAgain?.call();
  }
}
