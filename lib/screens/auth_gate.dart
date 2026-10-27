import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/app_card.dart';
import 'home_screen.dart';
import 'list_screen.dart';

/// Decides the first screen: Home when logged out, List when logged in.
/// While Firebase is still checking, only a loading indicator is shown.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<User?> _authStream =
      FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingView());
        }
        final user = snapshot.data;
        if (user == null) return const HomeScreen();
        return ListScreen(key: ValueKey(user.uid), user: user);
      },
    );
  }
}
