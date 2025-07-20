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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Results', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                  columns: const [
                    DataColumn(label: Text('Dummy Code')),
                    DataColumn(label: Text('Accuracy')),
                  ],
                  rows: dummyList.map((d) {
                    final acc =
                        (0.5 + dummyList.indexOf(d) * 0.015).toStringAsFixed(3);
                    return DataRow(
                      cells: [
                        DataCell(Text(d)),
                        DataCell(Text(acc)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
