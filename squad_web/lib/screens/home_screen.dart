// home_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

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
  List<Map<String, dynamic>> dummyData = [];
  final log = <String>['>: Ready.'];
  String selectedDummyCode = 'PQC'; // DummyGeneration용 단일 선택 상태
  WebSocketChannel? _logChannel;

  final nQubitsController = TextEditingController(text: '6');
  final batchSizeController = TextEditingController(text: '1');
  final deviceController = TextEditingController(text: 'cuda:0');
  final epochsController = TextEditingController(text: '5');
  final optimizerController = TextEditingController(text: 'Adam');
  final lrController = TextEditingController(text: '1e-4');

  Widget _divider() => Divider(color: Colors.grey[700], thickness: 1.0);

  @override
  void dispose() {
    _logChannel?.sink.close();
    super.dispose();
  }

  void connectLogWebSocket() {
    _logChannel?.sink.close(); // 기존 연결 종료
    _logChannel =
        WebSocketChannel.connect(Uri.parse('ws://localhost:8000/ws/logs'));
    _logChannel!.stream.listen((message) {
      setState(() {
        log.add('WS: $message');
      });
    }, onDone: () {
      setState(() {
        log.add('>: WebSocket closed');
      });
    }, onError: (error) {
      setState(() {
        log.add('>: WebSocket error: $error');
      });
    });
  }

  Future<void> generateDummies() async {
    connectLogWebSocket();
    setState(() {
      log.add('>: [Generate] Starting API request...');
    });

    // 기본 파라미터들
    String url =
        'http://127.0.0.1:8000/generate-code?n_qubits=${nQubitsController.text}&variant_count=${numberOfDummies.toString()}';

    // 각 선택된 Target Code를 개별 파라미터로 추가
    for (final code in selectedTargetCodes) {
      final partName = code == 'SE' ? 'encoder' : code.toLowerCase();
      url += '&target_parts=$partName';
    }

    await _sendApiRequest('/generate-code', url);
  }

  Future<void> runTestWithSavedWeights() async {
    setState(() {
      log.add('>: [Run] Starting API request...');
    });

    final queryParams = {
      'target_parts': selectedTargetCodes
          .map((code) => code == 'SE' ? 'encoder' : code)
          .join(','),
      'n_qubits': nQubitsController.text,
      'variant_counts': '3',
      'sample_count': '10',
      'dummy_codes': selectedDummyCodes
          .map((code) => code == 'SE' ? 'encoder' : code)
          .join(','),
      'layer': selectedLayer,
      'batch_size': batchSizeController.text,
      'device': deviceController.text,
      'train_epochs': epochsController.text,
      'optimizer': optimizerController.text,
      'lr': lrController.text,
      'variant_count': numberOfDummies.toString(),
    };

    await _sendApiRequest('/run-multi-test', queryParams);
  }

  Future<void> _sendApiRequest(String path, dynamic queryParams) async {
    try {
      Uri uri;
      if (queryParams is String) {
        // URL 문자열인 경우
        uri = Uri.parse(queryParams);
      } else {
        // Map인 경우 (기존 방식)
        final queryParametersAll = <String, List<String>>{};
        queryParams.forEach((key, value) {
          if (queryParametersAll.containsKey(key)) {
            queryParametersAll[key]!.add(value);
          } else {
            queryParametersAll[key] = [value];
          }
        });
        uri = Uri.http('127.0.0.1:8000', path, queryParametersAll);
      }

      setState(() {
        log.add('>: Sending GET request to: $uri');
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          log.add('>: API request successful!');
          // log.add('>: Response: ${response.body}');
          if (path == '/run-multi-test') {
            // results 배열에서 dummy_id별 info 파싱
            final results = responseData['results'] as List<dynamic>?;
            if (results != null) {
              dummyData = results.map<Map<String, dynamic>>((e) {
                final rawInfo = e['info'] ?? {};
                final info = <String, dynamic>{};
                rawInfo.forEach((k, v) {
                  info[k] = v is Map ? Map<String, dynamic>.from(v) : v;
                });
                return {
                  'dummy_id': e['dummy_id'].toString(),
                  'accuracy': e['accuracy'] ?? 0.0,
                  'info': info,
                };
              }).toList();
            } else {
              dummyData = [];
            }
          } else if (path == '/generate-code') {
            // generate-code API의 새로운 응답 구조 처리
            final results = responseData['results'] as List<dynamic>?;
            if (results != null) {
              dummyData = results.map<Map<String, dynamic>>((e) {
                final dummyParts =
                    e['dummy_parts'] as Map<String, dynamic>? ?? {};
                final info = <String, dynamic>{};

                // dummy_parts의 각 파트 정보를 info로 변환
                dummyParts.forEach((partKey, partValue) {
                  if (partValue is Map<String, dynamic>) {
                    final partInfo =
                        partValue['info'] as Map<String, dynamic>? ?? {};
                    // encoder를 SE로 변환하여 저장
                    final key = partKey == 'encoder' ? 'se' : partKey;
                    info[key] = partInfo;
                  }
                });

                return {
                  'dummy_id': e['dummy_id'].toString(),
                  'accuracy': 0.0, // generate-code는 accuracy 정보가 없으므로 기본값
                  'info': info,
                };
              }).toList();
            } else {
              dummyData = [];
            }
          }
        });
      } else {
        setState(() {
          log.add('>: API request failed with status: ${response.statusCode}');
          log.add('>: Error: ${response.body}');
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
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // 상단 고정 영역
                  PartSelection(
                    selectedTargetCodes: selectedTargetCodes,
                    selectedDummyCodes: selectedDummyCodes,
                    onTargetCodeChanged: (code, val) => setState(() {
                      if (val) {
                        selectedTargetCodes.add(code);
                      } else {
                        selectedTargetCodes.remove(code);
                      }
                      // Target Code 선택에 따라 Dummy Code 자동 업데이트
                      selectedDummyCodes.clear();
                      final allCodes = {'SE', 'PQC', 'MEA'};
                      for (final code in allCodes) {
                        if (!selectedTargetCodes.contains(code)) {
                          selectedDummyCodes.add(code);
                        }
                      }
                    }),
                    onDummyCodeChanged: (code, val) {
                      // Dummy Code는 수동 선택 불가능
                    },
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
                          onChanged: (val) =>
                              setState(() => selectedLayer = val),
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
                  // DummyGeneration을 Expanded로 감싸서 남은 공간을 모두 차지하도록 함
                  Expanded(
                    child: DummyGeneration(
                      dummyList: dummyData
                          .map((e) => e['dummy_id'] as String)
                          .toList(),
                      dummyData: dummyData,
                      selectedDummyCode: selectedDummyCode.isNotEmpty &&
                              dummyData.any(
                                  (e) => e['dummy_id'] == selectedDummyCode)
                          ? selectedDummyCode
                          : (dummyData.isNotEmpty
                              ? dummyData.first['dummy_id'] as String
                              : ''),
                      selectedDummyCodes: selectedDummyCodes,
                      onDummyCodeChanged: (code) => setState(() {
                        selectedDummyCode = code;
                      }),
                      onRunPressed: runTestWithSavedWeights,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: LogPanel(log: log)),
                  const SizedBox(height: 20),
                  _divider(),
                  Expanded(child: ResultsPanel(dummyData: dummyData)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
