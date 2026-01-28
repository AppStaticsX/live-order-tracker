import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/tracking/presentation/pages/customer_home_page.dart';
import 'features/tracking/presentation/pages/driver_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // This will fail if google-services.json is missing, which is expected for the user to add later.
    // We catch it so the app can still run the UI for demo purposes.
    await Firebase.initializeApp();
  } catch (e) {
    print(
      "Warning: Firebase initialization failed. Ensure google-services.json is present. Error: $e",
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Order Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/driver': (context) => const DriverHomePage(),
        '/customer': (context) => const CustomerHomePage(),
      },
    );
  }
}
