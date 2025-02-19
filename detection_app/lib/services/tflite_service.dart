import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  static final TFLiteService _instance = TFLiteService._internal();
  factory TFLiteService() => _instance;
  TFLiteService._internal();

  late Interpreter _interpreter;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset("assets/model_v2.tflite");
      print('✅ TFLite model loaded successfully.');
    } catch (e) {
      print('Error loading TFLite model: $e');
    }
  }

  Future<List<dynamic>> runModelOnImage(dynamic input) async {
    var output = List.filled(1, 0).reshape([1]);
    _interpreter.run(input, output);
    print('Inference result: $output');
    return output.cast<dynamic>();
  }

  void closeModel() {
    _interpreter.close();
    print('Model closed.');
  }
}
