import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
  // This widget is the root of your application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        bottomAppBarTheme: BottomAppBarThemeData(
          color: Colors.deepPurple,
        ), 
      ),
      home: LoginPage(),
    );
  }
}

