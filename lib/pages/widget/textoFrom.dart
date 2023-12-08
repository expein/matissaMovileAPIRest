import 'package:flutter/material.dart';

class Label extends StatefulWidget {
  final double screenWidth;
  final String dato;
  const Label({super.key, required this.screenWidth, required this.dato});

  @override
  State<Label> createState() => _LabelState();
}

class _LabelState extends State<Label> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}