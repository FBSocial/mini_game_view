import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:mini_game_view/mini_game_view.dart';
import 'package:mini_game_view/mini_game_view_platform_interface.dart';
import 'package:mini_game_view_example/keyboard_container.dart';

class GameViewArguments {
  final String gameName;
  final String roomId;
  final String gameId;
  final String userId;

  GameViewArguments({
    this.gameName = 'mini game',
    required this.roomId,
    required this.gameId,
    required this.userId,
  });
}

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  bool showMessage = true;
  final focusNode = FocusNode();
  late GameViewArguments arguments;

  @override
  void initState() {
    super.initState();
    arguments = Get.arguments as GameViewArguments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(arguments.gameName),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.red,
      body: Stack(
        children: [
          MiniGameView(
            roomId: arguments.roomId,
            gameId: arguments.gameId,
            userId: arguments.userId,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Visibility(
              visible: showMessage,
              child: Container(
                color: Colors.grey.withOpacity(.2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 150 - 48,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: 100,
                        itemBuilder: (_, index) {
                          return SizedBox(
                            height: 24,
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Text(
                                  '玩家${index + 1}:',
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text('听说这个游戏很好玩，是不是啊， ${index + 1}'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      color: Colors.grey.withOpacity(.3),
                      height: 48,
                      padding: const EdgeInsets.only(left: 16),
                      child: TextField(
                        focusNode: focusNode,
                        decoration: const InputDecoration(hintText: '说点什么吧'),
                      ),
                    ),
                    KeyboardContainer(focusNode: focusNode),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: updateMessageShowStatus,
            child: const Text('弹幕'),
          ),
          // FloatingActionButton(
          //   onPressed: loadingGame,
          //   child: const Text('加载'),
          // ),
        ],
      ),
    );
  }

  void updateMessageShowStatus() {
    setState(() {
      showMessage = !showMessage;
    });
  }

  Future<void> loadingGame() async {
    MiniGameViewPlatform.instance.loadGameView();
  }
}
