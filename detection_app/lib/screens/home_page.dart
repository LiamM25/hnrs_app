import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_button.dart';
import '../services/tflite_service.dart';
import 'package:image/image.dart' as img;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _topPrediction;
  List<Map<String, dynamic>>? _allPredictions;
  bool _isLoading = false;

  final List<String> _labels = [
    'Melanocytic nevi',
    'Melanoma',
    'Benign keratosis-like lesions',
    'Basal cell carcinoma',
    'Actinic keratoses',
    'Vascular lesions',
    'Dermatofibroma'
  ];

  String _interpretPrediction(String label) {
    if (label == 'Melanoma' || label == 'Basal cell carcinoma') {
      return 'High risk of cancerous lesion. It is strongly advised to consult a doctor immediately.';
    } else if (label == 'Actinic keratoses') {
      return 'Possible pre-cancerous lesion. A medical consultation is recommended.';
    } else {
      return 'The lesion appears non-cancerous, but regular monitoring is suggested. If you have concerns, consult a doctor.';
    }
  }

  Future<List<List<List<List<int>>>>> _preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    img.Image resizedImage = img.copyResize(image, width: 32, height: 32);

    final input = List.generate(
      1,
      (_) => List.generate(
        32,
        (y) => List.generate(
          32,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r.toInt(),
              pixel.g.toInt(),
              pixel.b.toInt(),
            ];
          },
        ),
      ),
    );

    return input;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _classifyImage(_selectedImage!);
    }
  }

  Future<void> _classifyImage(File image) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final preprocessedImage = await _preprocessImage(image);
      final rawPredictions =
          await TFLiteService().runModelOnImage(preprocessedImage);

      final predictions = List.generate(
        rawPredictions.length,
        (index) => {
          "label": _labels[index],
          "confidence": rawPredictions[index],
        },
      );

      predictions.sort((a, b) =>
          (b['confidence'] as double).compareTo(a['confidence'] as double));

      setState(() {
        _topPrediction = predictions.first;
        _allPredictions = predictions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMoreInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detailed Results'),
        content: _allPredictions != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: _allPredictions!
                    .map(
                      (res) => Text(
                          "${res["label"]}: ${(res["confidence"] * 100).toStringAsFixed(2)}%"),
                    )
                    .toList(),
              )
            : const Text('No additional data available.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFe8f7fc), Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Skin Scanner',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF37a4ea),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI-powered analysis',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _selectedImage == null
                    ? const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                label: 'Upload Image',
                onPressed: _pickImage,
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_topPrediction != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Result: ${_topPrediction!["label"]}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Confidence: ${( (_topPrediction!["confidence"] ?? 0.0) * 100).toStringAsFixed(2)}%",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _interpretPrediction(_topPrediction!["label"]),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 15),
                    CustomButton(
                      label: 'More Info',
                      onPressed: _showMoreInfoDialog,
                    ),
                  ],
                )
              else
                const Text('No predictions yet.'),
            ],
          ),
        ),
      ),
    );
  }
}
