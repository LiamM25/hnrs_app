import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_button.dart';
import '../services/tflite_service.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>>? _predictions;
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
    print('🔄 Starting classification...');
    setState(() {
      _isLoading = true;
    });
    try {
      final preprocessedImage = await _preprocessImage(image);
      print('🔍 Preprocessed image shape: ${preprocessedImage.length}');
      final rawPredictions =
          await TFLiteService().runModelOnImage(preprocessedImage);
      print('🚀 Inference output: $rawPredictions');

      final predictions = List.generate(
        rawPredictions.length,
        (index) => {
          "label": _labels[index],
          "confidence": rawPredictions[index],
        },
      );

      setState(() {
        _predictions = predictions;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Classification error: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
                'Skin Scan',
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
              if (_isLoading)
                const CircularProgressIndicator()
              else
                _predictions != null && _predictions!.isNotEmpty
                    ? Column(
                        children: _predictions!
                            .map((res) => Text(
                                  "${res["label"]}: ${(res["confidence"] * 100).toStringAsFixed(2)}%",
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ))
                            .toList(),
                      )
                    : const Text('No predictions yet.'),
              const SizedBox(height: 30),
              CustomButton(
                label: 'Upload Image',
                onPressed: _pickImage,
              ),
              const SizedBox(height: 15),
              CustomButton(
                label: 'Classify Now',
                onPressed: _selectedImage != null
                    ? () {
                        print('🚀 Classify button pressed');
                        _classifyImage(_selectedImage!);
                      }
                    : () {},
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      DefaultTabController.of(context)?.animateTo(1);
                    },
                    child: const Text(
                      'View Results',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF37a4ea),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      DefaultTabController.of(context)?.animateTo(2);
                    },
                    child: const Text(
                      'More Info',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF37a4ea),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
