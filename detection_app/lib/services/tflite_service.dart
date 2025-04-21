import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  static final TFLiteService _instance = TFLiteService._internal();
  factory TFLiteService() => _instance;
  TFLiteService._internal();

  late Interpreter _interpreter;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset("assets/model_v2.tflite");
      print('TFLite model loaded successfully.');
    } catch (e) {
      print('Error loading TFLite model: $e');
    }
  }

Future<List<dynamic>> runModelOnImage(List<List<List<List<int>>>> input) async {
  try {
    final output = List.generate(1, (_) => List.filled(7, 0.0));
    _interpreter.run(input, output); // Running inference
    print('Inference output: $output');
    return output[0]; // Return the first element which contains the predictions
  } catch (e) {
    print('Error during inference: $e');
    rethrow;
  }
}

  void closeModel() {
    _interpreter.close();
    print('Model closed.');
  }
}
