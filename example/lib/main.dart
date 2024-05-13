import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mini_game_view/mini_game_view.dart';
import 'package:mini_game_view/mini_game_view_platform_interface.dart';
import 'package:mini_game_view_example/keyboard_container.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('这里应该是游戏列表页面或入口页'),
              const Text('点击加号进入游戏页面'),
              Builder(
                builder: (ctx) {
                  return IconButton(
                    onPressed: () {
                      Navigator.of(ctx).push(
                          MaterialPageRoute(builder: (_) => const GameView()));
                    },
                    icon: const Icon(Icons.add),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  bool showMessage = true;
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Plugin Test'),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.red,
      body: Stack(
        children: [
          Column(
            children: const [
              Expanded(child: MiniGameView()),
              SizedBox(height: 300, child: Center(child: Text('Flutter View'))),
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
    // MiniGameViewPlatform.instance.getPlatformVersion();
    MiniGameViewPlatform.instance
        .loadGameView(roomId: "10000", gameId: "1468434401847222273");
  }
}
