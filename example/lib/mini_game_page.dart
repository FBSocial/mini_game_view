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
          Column(
            children: [
              Expanded(
                child: MiniGameView(
                  roomId: arguments.roomId,
                  gameId: arguments.gameId,
                  userId: arguments.userId,
                ),
              ),
              const SizedBox(
                height: 300,
                child: Center(child: Text('Flutter Placeholder View')),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Visibility(
              visible: showMessage,
              child: Container(
                color: Colors.grey.withOpacity(.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 300 - 52,
                      child: ListView.builder(
                        itemCount: 100,
                        itemBuilder: (_, index) {
                          return ListTile(
                              title: Text('听说这个游戏很好玩，是不是啊， ${index + 1}'));
                        },
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      height: 52,
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
          FloatingActionButton(
            onPressed: loadingGame,
            child: const Text('加载'),
          ),
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
