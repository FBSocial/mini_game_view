import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini_game_view_example/mini_game_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TextEditingController _userIdController;
  late TextEditingController _roomIdController;

  @override
  void initState() {
    super.initState();
    _userIdController = TextEditingController(
        text: DateTime.now().millisecondsSinceEpoch.toString());
    _roomIdController = TextEditingController(text: '10000');
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('游戏大厅列表'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text('房间信息'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 24),
                const Text('userId:'),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(controller: _userIdController),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 24),
                const Text('roomId:'),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(controller: _roomIdController),
                ),
              ],
            ),
            Container(
              color: Colors.black.withOpacity(.1),
              margin: const EdgeInsets.only(top: 16),
              height: 16,
            ),
            const Text('游戏列表'),
            Expanded(
              child: ListView(
                children: [
                  _buildGameItem('飞行棋', '1468180338417074177'),
                  _buildGameItem('跳一跳', '1680881367829176322'),
                  _buildGameItem('扫雷雷', '1468434401847222273'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameItem(String gameName, String gameId) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openGameView(gameName, gameId),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            const SizedBox(width: 24),
            const Icon(Icons.games),
            const SizedBox(width: 24),
            Text(gameName),
          ],
        ),
      ),
    );
  }

  void openGameView(String gameName, String gameId) {
    Get.to(
      () => const GameView(),
      arguments: GameViewArguments(
        gameName: gameName,
        gameId: gameId,
        userId: _userIdController.text,
        roomId: _roomIdController.text,
      ),
    );
  }
}
