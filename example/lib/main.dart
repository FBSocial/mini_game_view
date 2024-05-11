import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mini_game_view/mini_game_view.dart';
import 'package:mini_game_view/mini_game_view_platform_interface.dart';

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
        backgroundColor: Colors.red,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Plugin Test'),
      ),
      backgroundColor: Colors.red,
      body:  Column(
        children: const [
          SizedBox(height: 500, child: MiniGameView()),
          Expanded(child: Center(child: Text('Flutter View')))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: test,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> test() async {
    // MiniGameViewPlatform.instance.getPlatformVersion();
    MiniGameViewPlatform.instance
        .loadGameView(roomId: "10000", gameId: "1468434401847222273");
  }
}
