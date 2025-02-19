import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/results_page.dart';
import 'screens/disclaimer_page.dart';
import 'services/tflite_service.dart';  // ✅ Import the TFLite service

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Required for async in main
  await TFLiteService().loadModel();          // ✅ Load TFLite model before app runs
  runApp(const SkinCancerDetectionApp());
}

class SkinCancerDetectionApp extends StatelessWidget {
  const SkinCancerDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    ResultsPage(),
    DisclaimerPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    TFLiteService().closeModel(); // ✅ Optional: Close model when app is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF37a4ea),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Results'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Disclaimer'),
        ],
      ),
    );
  }
}
