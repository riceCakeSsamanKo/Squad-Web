import 'package:flutter/material.dart';

class DummyGeneration extends StatelessWidget {
  final List<String> dummyList;
  final Set<String> selectedDummyCodes;

  const DummyGeneration({
    super.key,
    required this.dummyList,
    required this.selectedDummyCodes,
  });

  @override
  Widget build(BuildContext context) {
    final orderedCodes = ['SE', 'PQC', 'MEA']
        .where((code) => selectedDummyCodes.contains(code))
        .toList();

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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dummy Code Generation',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton(onPressed: null, child: Text('Run')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dummy List
              Container(
                width: 120,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: dummyList.map((dummy) {
                    return Row(
                      children: [
                        Checkbox(value: false, onChanged: (_) {}),
                        Expanded(child: Text(dummy)),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 12),
              // Visualization + Details
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: orderedCodes
                      .map((code) => Expanded(
                            child: Container(
                              height: 150,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: code == 'PQC' || code == 'SE'
                                    ? Colors.green.shade100.withOpacity(0.3)
                                    : Colors.red.shade100.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(code,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  if (code == 'PQC' || code == 'SE') ...[
                                    const Text('• layer : RXYZCXLAYER'),
                                    const Text('• n_blocks : 4'),
                                    const Text('• n_qubits : 6'),
                                  ] else if (code == 'MEA') ...[
                                    const Text('• layer : MeasureAll'),
                                    const Text('• operator : Pauli-Z'),
                                    const Text('• n_qubits : 6'),
                                  ]
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
