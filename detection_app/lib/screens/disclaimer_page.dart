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
            'This application is developed for research and educational purposes only. It provides predictions based on a machine learning model trained on a specific dataset and should not be considered a substitute for professional medical advice, diagnosis, or treatment.\n\n'
            '- The model\'s predictions are limited to the accuracy of the dataset it was trained on and may not generalise to all real-world cases.\n'
            '- If you have any concerns regarding your health or the results provided by this app, consult a qualified healthcare provider immediately.\n'
            '- Never disregard professional medical advice or delay seeking it because of something you have read in this application.\n\n'
            'By using this app, you acknowledge that the developers are not responsible for any decisions made based on its output.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
