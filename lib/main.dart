import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/auth/login_view.dart';
import 'views/dashboards/dashboard_view.dart';
import 'views/dashboards/invigilator_dashboard_view.dart';
import 'views/dashboards/chief_invigilator_dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthViewModel())],
      child: const ExamAssistApp(),
    ),
  );
}

class ExamAssistApp extends StatelessWidget {
  const ExamAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExamAssist',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const AuthGate(),
      //home: const InvigilatorDashboardView(),
      //home: const ChiefInvigilatorDashboardView(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final firebaseUser = authSnapshot.data;

        if (firebaseUser == null) {
          return const LoginView();
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text('User profile not found')),
              );
            }

            final userData = userSnapshot.data!.data()!;
            final role = userData['role'] as String?;

            if (role == null) {
              return const Scaffold(
                body: Center(child: Text('User role not assigned')),
              );
            }

            switch (role) {
              case 'Assistant Invigilator':
                return DashboardView(role: role);
              case 'Invigilator':
                return const InvigilatorDashboardView();
              case 'Chief Invigilator':
                return const ChiefInvigilatorDashboardView();

              default:
                return const Scaffold(
                  body: Center(child: Text('Invalid user role')),
                );
            }
          },
        );
      },
    );
  }
}
