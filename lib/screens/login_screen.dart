import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../core/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_inputs.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitted = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      // The app root now shows the List screen; drop this form from the
      // stack so Back on the List screen cannot return here.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message ?? e.code;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: Strings.login),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Welcome back', style: AppText.title),
              const SizedBox(height: AppSpacing.xs),
              const Text('Sign in to see your books.', style: AppText.muted),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Form(
                  key: _formKey,
                  autovalidateMode: _submitted
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _email,
                        label: Strings.email,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                        enabled: !_loading,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _password,
                        label: Strings.password,
                        icon: Icons.lock_outline,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        validator: Validators.loginPassword,
                        enabled: !_loading,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: Strings.login,
                        icon: Icons.login,
                        expand: true,
                        loading: _loading,
                        onPressed: _submit,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        FormMessage.error(_error!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: "Don't have an account? ${Strings.register}",
                variant: AppButtonVariant.text,
                onPressed: _loading
                    ? null
                    : () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
