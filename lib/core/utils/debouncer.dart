import 'package:flutter/material.dart';

/// Debounces rapid callbacks (e.g. search bar input)
class Debouncer {
  final Duration delay;
  VoidCallback? _action;
  bool _isDisposed = false;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void call(VoidCallback action) {
    _action = action;
    Future.delayed(delay, () {
      if (!_isDisposed && _action == action) {
        _action?.call();
      }
    });
  }

  void cancel() => _action = null;

  void dispose() {
    _isDisposed = true;
    _action = null;
  }
}
