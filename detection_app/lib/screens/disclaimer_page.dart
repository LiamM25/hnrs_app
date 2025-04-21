import 'package:flutter/material.dart';

class DisclaimerPage extends StatelessWidget {
  const DisclaimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Disclaimer:\n\n'
            'This application is developed for research and educational purposes only. It provides predictions based on a machine learning model trained on a specific dataset and should not be considered a substitute for professional medical advice, diagnosis, or treatment.\n\n',
            
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
