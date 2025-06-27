// home_screen.dart
import 'package:flutter/material.dart';

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
  String selectedTargetCode = 'SE';
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
  final deviceController = TextEditingController(text: 'cuda 0');
  final epochsController = TextEditingController(text: '5');
  final optimizerController = TextEditingController(text: 'Adam');
  final lrController = TextEditingController(text: '1e-4');

  Widget _divider() => Divider(color: Colors.grey[700], thickness: 1.0);

  void generateDummies() {
    setState(() {
      dummyList =
          List.generate(numberOfDummies, (index) => 'Dummy#${index + 1}');
      for (final dummy in dummyList) {
        log.add('>: $dummy split learning started ... Done!');
      }
    });
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
                  selectedTargetCode: selectedTargetCode,
                  selectedDummyCodes: selectedDummyCodes,
                  onTargetCodeChanged: (val) =>
                      setState(() => selectedTargetCode = val),
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
