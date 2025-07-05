// home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/code_layer.dart';
import '../widgets/dummy_generation.dart';
import '../widgets/hyperparameter_config.dart';
import '../widgets/log_panel.dart';
import '../widgets/part_selection.dart';
import '../widgets/results_panel.dart';

class QuantumHomePage extends StatefulWidget {
  const QuantumHomePage({super.key});

  @override
  _QuantumHomePageState createState() => _QuantumHomePageState();
}

class _QuantumHomePageState extends State<QuantumHomePage> {
  Set<String> selectedTargetCodes = {'SE'};
  Set<String> selectedDummyCodes = {'PQC', 'MEA'};
  String selectedLayer = 'StateEncoder';
  int numberOfDummies = 5;
  List<String> dummyList = [];
  final log = <String>[
    '>: Selected SE for Target Code',
    '>: Selected PQC, MEA for Dummy Code',
    '>: Building Target Code ... Success!',
    '>: Building Dummy Codes ... Success!'
  ];

  final nQubitsController = TextEditingController(text: '6');
  final batchSizeController = TextEditingController(text: '1');
  final deviceController = TextEditingController(text: 'cuda:0');
  final epochsController = TextEditingController(text: '5');
  final optimizerController = TextEditingController(text: 'Adam');
  final lrController = TextEditingController(text: '1e-4');

  Widget _divider() => Divider(color: Colors.grey[700], thickness: 1.0);

  Future<void> generateDummies() async {
    setState(() {
      log.add('>: Starting API request...');
    });

    final queryParams = {
      'target_parts': selectedTargetCodes.join(','),
      'n_qubits': nQubitsController.text,
      'variant_counts': '3',
      'sample_count': '10',
      'dummy_codes': selectedDummyCodes.join(','),
      'layer': selectedLayer,
      'batch_size': batchSizeController.text,
      'device': deviceController.text,
      'epochs': epochsController.text,
      'optimizer': optimizerController.text,
      'lr': lrController.text,
      'num_dummies': numberOfDummies.toString(),
    };

    try {
      final uri = Uri.http('127.0.0.1:8000', '/run-multi-test', queryParams);
      
      setState(() {
        log.add('>: Sending GET request to: $uri');
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          log.add('>: API request successful!');
          log.add('>: Response: ${response.body}');
          // Assuming the response gives us a list of dummies to populate
          // For now, we'll just use the old logic as a placeholder
          dummyList = List.generate(numberOfDummies, (index) => 'Dummy#\${index + 1}');
        });
      } else {
        setState(() {
          log.add('>: API request failed with status: \${response.statusCode}');
          log.add('>: Error: \${response.body}');
        });
      }
    } catch (e) {
      setState(() {
        log.add('>: An error occurred while sending the request:');
        log.add(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quantum Split Learning UI')),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                PartSelection(
                  selectedTargetCodes: selectedTargetCodes,
                  selectedDummyCodes: selectedDummyCodes,
                  onTargetCodeChanged: (code, val) => setState(() {
                    val
                        ? selectedTargetCodes.add(code)
                        : selectedTargetCodes.remove(code);
                  }),
                  onDummyCodeChanged: (code, val) => setState(() {
                    val
                        ? selectedDummyCodes.add(code)
                        : selectedDummyCodes.remove(code);
                  }),
                ),
                const SizedBox(height: 20),
                _divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: CodeLayer(
                        selectedLayer: selectedLayer,
                        onChanged: (val) => setState(() => selectedLayer = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: HyperparameterConfig(
                        nQubitsController: nQubitsController,
                        batchSizeController: batchSizeController,
                        deviceController: deviceController,
                        epochsController: epochsController,
                        optimizerController: optimizerController,
                        lrController: lrController,
                        numberOfDummies: numberOfDummies,
                        onNumberChanged: (val) =>
                            setState(() => numberOfDummies = val),
                        onGeneratePressed: generateDummies,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _divider(),
                DummyGeneration(
                  dummyList: dummyList,
                  selectedDummyCodes: selectedDummyCodes,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LogPanel(log: log),
                  const SizedBox(height: 20),
                  _divider(),
                  ResultsPanel(dummyList: dummyList),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}