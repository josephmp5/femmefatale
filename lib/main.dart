import 'package:femmefatale/home_page.dart';
import 'package:femmefatale/onboard_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // Check if the user is signed in
            if (snapshot.hasData && snapshot.data != null) {
              // Ensure the user is not null

              return const HomePage(); // Navigate to the HomePage if signed in
            }
            return const OnboardPage(); // Otherwise, show the OnBoard page
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ); // Show loading screen while waiting
        },
      ),
    );
  }
}
