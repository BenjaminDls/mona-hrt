import 'package:flutter/material.dart';

class MainPageWrapper extends StatelessWidget {
  final bool isLoading;
  final bool isEmpty;
  final Widget child;
  final Widget emptyChildWidget;

  const MainPageWrapper({
    required this.isLoading,
    required this.isEmpty,
    required this.child,
    required this.emptyChildWidget,
  }) : super();

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (isEmpty) return Center(child: emptyChildWidget);
    return child;
  }
}
