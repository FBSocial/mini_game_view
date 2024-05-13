import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class MiniGameView extends StatelessWidget {
  final String roomId;
  final String gameId;
  final String userId;

  const MiniGameView({
    required this.roomId,
    required this.gameId,
    required this.userId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const String viewType = '<mini-game-view-type>';
    Map<String, dynamic> creationParams = <String, dynamic>{};
    creationParams['roomId'] = roomId;
    creationParams['gameId'] = gameId;
    creationParams['userId'] = userId;
    if (Platform.isIOS) {
      return const UiKitView(
        viewType: 'my_custom_view',
        creationParams: {'viewId': 'miniGame'},
        creationParamsCodec: StandardMessageCodec(),
      );
    }
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
}
