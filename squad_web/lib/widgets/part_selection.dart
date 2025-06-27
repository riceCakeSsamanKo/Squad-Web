// part_selection.dart
import 'package:flutter/material.dart';

class PartSelection extends StatelessWidget {
  final String selectedTargetCode;
  final Set<String> selectedDummyCodes;
  final Function(String) onTargetCodeChanged;
  final Function(String, bool) onDummyCodeChanged;

  const PartSelection({
    super.key,
    required this.selectedTargetCode,
    required this.selectedDummyCodes,
    required this.onTargetCodeChanged,
    required this.onDummyCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Part Selection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // Target and Dummy Code Sections Side by Side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target Code
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade800.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target Code:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: ['SE', 'PQC', 'MEA'].map((code) {
                          return Row(
                            children: [
                              Checkbox(
                                value: selectedTargetCode == code,
                                onChanged: (_) => onTargetCodeChanged(code),
                              ),
                              Text(code),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Dummy Code
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade800.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dummy Code:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: ['SE', 'PQC', 'MEA'].map((code) {
                          return Row(
                            children: [
                              Checkbox(
                                value: selectedDummyCodes.contains(code),
                                onChanged: (val) =>
                                    onDummyCodeChanged(code, val ?? false),
                              ),
                              Text(code),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
