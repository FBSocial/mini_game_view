import 'package:mini_game_view/mini_game_info.dart';

class MiniGameController {
  final MiniGameInfo info;

  final MiniGameConfig config;

  final MiniGameViewPosition? position;

  final Future<String> Function() loginCodeCallback;

  MiniGameController({
    required this.config,
    required this.info,
    required this.loginCodeCallback,
    this.position,
  });
}
