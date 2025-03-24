import 'package:flutter/material.dart';

class WaterControlData extends StatelessWidget {
  const WaterControlData({super.key, required this.text, required this.value});
  final String text;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(text), Text(value)],
      ),
    );
  }
}
