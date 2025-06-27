// results_panel.dart
import 'package:flutter/material.dart';

class ResultsPanel extends StatelessWidget {
  final List<String> dummyList;

  const ResultsPanel({
    super.key,
    required this.dummyList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Results', style: TextStyle(fontSize: 20)),
        DataTable(
          columns: const [
            DataColumn(label: Text('Dummy Code')),
            DataColumn(label: Text('Accuracy')),
          ],
          rows: dummyList.map((d) {
            final acc = (0.5 + dummyList.indexOf(d) * 0.015).toStringAsFixed(3);
            return DataRow(
              cells: [
                DataCell(Text(d)),
                DataCell(Text(acc)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
