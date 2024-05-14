import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mini_game_view/mini_game_controller.dart';

class MiniGameView extends StatelessWidget {
  final MiniGameController controller;

  const MiniGameView({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const String viewType = 'mini-game-view-type';
    Map<String, dynamic> creationParams = <String, dynamic>{};

    final config = controller.config;
    creationParams['appId'] = config.appId;
    creationParams['appKey'] = config.appKey;
    creationParams['isTestEnv'] = config.isTestEnv;

    final info = controller.info;
    creationParams['roomId'] = info.roomId;
    creationParams['gameId'] = info.gameId;
    creationParams['userId'] = info.userId;

    final position = controller.position;
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
}
