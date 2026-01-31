import 'package:flutter/material.dart';

import 'app_state.dart';

class AppStateScope extends InheritedWidget {
  const AppStateScope({
    super.key,
    required this.state,
    required super.child,
  });

  final AppState state;

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found');
    return scope!.state;
  }

  @override
  bool updateShouldNotify(AppStateScope oldWidget) => state != oldWidget.state;
}
