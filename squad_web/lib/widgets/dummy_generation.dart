import 'package:flutter/material.dart';

class DummyGeneration extends StatelessWidget {
  final List<String> dummyList;
  final String selectedDummyCode;
  final Set<String> selectedDummyCodes; // 추가: PartSelection에서 선택된 Dummy Code들
  final VoidCallback onRunPressed;
  final Function(String) onDummyCodeChanged;

  const DummyGeneration({
    super.key,
    required this.dummyList,
    required this.selectedDummyCode,
    required this.selectedDummyCodes,
    required this.onRunPressed,
    required this.onDummyCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final orderedCodes = ['SE', 'PQC', 'MEA']
        .where((code) => selectedDummyCodes.contains(code))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dummy Code Generation', style: textTheme.titleLarge),
                ElevatedButton(
                    onPressed: onRunPressed, child: const Text('Run')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dummy List
                Container(
                  width: 150,
                  height: 180,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                        child: Text("Dummy List", style: textTheme.titleSmall),
                      ),
                      Expanded(
                        child: ListView(
                          children: dummyList.map((dummy) {
                            return Row(
                              children: [
                                Radio<String>(
                                  value: dummy,
                                  groupValue: selectedDummyCode,
                                  onChanged: (val) {
                                    if (val != null) onDummyCodeChanged(val);
                                  },
                                ),
                                Expanded(child: Text(dummy)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Visualization + Details
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: orderedCodes.map((code) {
                      final isGood = code == 'PQC' || code == 'SE';
                      return Expanded(
                        child: Container(
                          height: 180,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isGood
                                  ? Colors.green.shade200
                                  : Colors.grey.shade400, // Changed from red
                            ),
                            color: isGood
                                ? Colors.green.shade50.withOpacity(0.5)
                                : Colors.grey.shade200
                                    .withOpacity(0.5), // Changed from red
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                code,
                                style: textTheme.titleMedium?.copyWith(
                                  color: isGood
                                      ? Colors.green.shade900
                                      : Colors
                                          .grey.shade800, // Changed from red
                                ),
                              ),
                              const Divider(),
                              ..._buildCodeDetails(context, code),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCodeDetails(BuildContext context, String code) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    switch (code) {
      case 'PQC':
      case 'SE':
        return [
          Text('• layer : RXYZCXLAYER', style: textStyle),
          Text('• n_blocks : 4', style: textStyle),
          Text('• n_qubits : 6', style: textStyle),
        ];
      case 'MEA':
        return [
          Text('• layer : MeasureAll', style: textStyle),
          Text('• operator : Pauli-Z', style: textStyle),
          Text('• n_qubits : 6', style: textStyle),
        ];
      default:
        return [];
    }
  }
}
