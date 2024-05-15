import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini_game_view/mini_game_controller.dart';
import 'package:mini_game_view/mini_game_info.dart';
import 'dart:async';

import 'package:mini_game_view/mini_game_view.dart';
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
  late MiniGameController miniGameController;

  @override
  void initState() {
    super.initState();
    arguments = Get.arguments as GameViewArguments;
    miniGameController = MiniGameController(
      config: MiniGameConfig(
        appId: '1461564080052506636',
        appKey: '03pNxK2lEXsKiiwrBQ9GbH541Fk2Sfnc',
        isTestEnv: true,
      ),
      info: MiniGameInfo(
        userId: arguments.userId,
        gameId: arguments.gameId,
        roomId: arguments.roomId,
      ),
      position: MiniGameViewPosition(bottom: 150),
      loginCodeCallback: getLoginCode,
    );
  }

  @override
  void dispose() {
    miniGameController.dispose();
    super.dispose();
  }

  Future<String> getLoginCode() async {
    String code = '';
    try {
      final dio = Dio();
      dio.options.responseType = ResponseType.json;
      final result =
          await dio.post('https://mgp-hello.sudden.ltd/login/v3', data: {
        'user_id': arguments.userId,
      });
      final data = result.data;
      // {
      //   ret_code: 0,
      //   data: {
      //      code: 0!@#$!eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiIxNzE1NjY5ODQxNDMwIiwiZXhwIjoxNzE1NjczNDczLCJhcHBfaWQiOiIxNDYxNTY0MDgwMDUyNTA2NjM2In0.qqWDaQau6YTv27_I2tQwi5Qq6B9rPcPT-Yofw0bwOuY,
      //      expire_date: 1715673473890,
      //      avatar_url: https://dev-sud-static.sudden.ltd/avatar/13.jpg
      //   }
      // }
      if (data is Map && data['data'] != null && data['data'] is Map) {
        code = data['data']['code'];
      }
    } catch (e) {
      print(e.toString());
    }
    return code;
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
          MiniGameView(controller: miniGameController),
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
        ],
      ),
    );
  }

  void updateMessageShowStatus() {
    setState(() {
      showMessage = !showMessage;
    });
  }
}
