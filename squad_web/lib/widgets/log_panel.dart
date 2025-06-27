// log_panel.dart
import 'package:flutter/material.dart';

class LogPanel extends StatelessWidget {
  final List<String> log;

  const LogPanel({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.black54,
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: log
              .map((entry) => Text(
                    entry,
                    style: const TextStyle(fontSize: 12),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
