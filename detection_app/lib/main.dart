import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/disclaimer_page.dart';
import 'services/tflite_service.dart';  

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await TFLiteService().loadModel();          
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
    DisclaimerPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    TFLiteService().closeModel(); 
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
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Disclaimer'),
        ],
      ),
    );
  }
}
