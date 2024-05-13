import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class KeyboardContainer extends StatefulWidget {
  final FocusNode? focusNode;

  const KeyboardContainer({Key? key, required this.focusNode})
      : super(key: key);

  @override
  _KeyboardContainerState createState() => _KeyboardContainerState();
}

/// 隐藏、拓展键盘、输入键盘
enum KeyboardStatus {
  hide,
  inputKeyboard,
}

double getBottomViewInset() {
  return Get.mediaQuery.padding.bottom;
}

class _KeyboardContainerState extends State<KeyboardContainer>
    with SingleTickerProviderStateMixin {
  Stream<bool> get onChange => _keyboardController.onChange;
  StreamSubscription? _keyboardSubscription;

  double _keyboardHeight = 0; //键盘高度

  double _bottomInset = 0;

  @override
  void initState() {
    // _bottomInset = getBottomViewInset();
    _keyboardController = KeyboardVisibilityController();
    _animationController =
        AnimationController(duration: kThemeAnimationDuration, vsync: this);
    _animation =
        Tween(begin: _bottomInset, end: 200).animate(_animationController!);

    _keyboardSubscription = onChange.listen((event) {
      if (event) {
        animateTo(KeyboardStatus.inputKeyboard);
      } else if (!widget.focusNode!.hasFocus) {
        widget.focusNode?.unfocus();
        animateTo(KeyboardStatus.hide);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _animationController = null;
    _keyboardSubscription?.cancel();
    super.dispose();
  }

  /// animation
  AnimationController? _animationController;
  late Animation _animation;

  late KeyboardVisibilityController _keyboardController;

  void _animateTo(double to) {
    if (_animationController == null) return;
    if (_animation.status == AnimationStatus.forward) {
      _animationController!.stop();
    }
    _animation = Tween<double>(begin: _animation.value * 1.0, end: to).animate(
        CurvedAnimation(
            parent: _animationController!, curve: Curves.easeOutCirc));

    _animationController!
      ..value = 0.0
      ..forward();
  }

  void animateTo(KeyboardStatus status) {
    if (_animationController == null) return;
    switch (status) {
      case KeyboardStatus.hide:
        _animateTo(_bottomInset);
        break;
      case KeyboardStatus.inputKeyboard:
        if (_keyboardHeight == 0) {
          Future.delayed(
              kThemeAnimationDuration, () => _animateTo(_keyboardHeight));
        } else {
          _animateTo(_keyboardHeight);
        }
        break;
    }
  }

  void _shouldUpdateKeyboardHeight() {
    _keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (widget.focusNode?.hasFocus ?? false) {
      animateTo(KeyboardStatus.inputKeyboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    _shouldUpdateKeyboardHeight();
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: _animation.value * 1.0,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
        );
      },
    );
  }
}
