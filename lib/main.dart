import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voiceinvoice/views/Intermediate.dart';
import 'package:voiceinvoice/views/Login.dart';
import 'package:voiceinvoice/views/HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Invoice',
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
      routes: {
        '/login': (context) => Login(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

Future<bool> delay() async {
  await Future.delayed(Duration(seconds: 2));
  return true;
}

// AuthGate checks if user is logged in
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return FutureBuilder(
            future: delay(),
            builder: (context, status) {
              if (status.connectionState == ConnectionState.waiting) {
                return Intermediate();
              }
              if (status.connectionState == ConnectionState.done) {
                return HomePage();
              }
              return HomePage();
            },
          ); // User is logged in
        }
        return Login(); // User is NOT logged in
      },
    );
  }
}
