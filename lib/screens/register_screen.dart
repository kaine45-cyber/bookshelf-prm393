import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../core/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_inputs.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _submitted = false;
  bool _loading = false;
  bool _success = false;
  String? _error;
  Timer? _redirect;

  @override
  void dispose() {
    _redirect?.cancel();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
      // Creates a real account; Firebase also signs the new user in.
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _success = true;
      });
      // Leave the message on screen for a moment, then go to the List screen.
      _redirect = Timer(const Duration(seconds: 3), _goToList);
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

  void _goToList() {
    _redirect?.cancel();
    if (!mounted) return;
    // The app root already shows the List screen for the new user.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final busy = _loading || _success;
    return Scaffold(
      appBar: buildAppBar(title: Strings.register),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create your account', style: AppText.title),
              const SizedBox(height: AppSpacing.xs),
              const Text('Start your private book list.', style: AppText.muted),
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
                        enabled: !busy,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _password,
                        label: Strings.password,
                        icon: Icons.lock_outline,
                        obscure: true,
                        textInputAction: TextInputAction.next,
                        validator: Validators.registerPassword,
                        enabled: !busy,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _confirm,
                        label: Strings.confirmPassword,
                        icon: Icons.lock_outline,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        validator:
                            Validators.confirmPassword(() => _password.text),
                        enabled: !busy,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: Strings.register,
                        icon: Icons.person_add_alt_1,
                        expand: true,
                        loading: _loading,
                        onPressed: _success ? null : _submit,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        FormMessage.error(_error!),
                      ],
                      if (_success) ...[
                        const SizedBox(height: AppSpacing.md),
                        const FormMessage.success(
                            Strings.registrationSuccessful),
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          label: 'Continue to my books',
                          variant: AppButtonVariant.outline,
                          expand: true,
                          onPressed: _goToList,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Already have an account? ${Strings.login}',
                variant: AppButtonVariant.text,
                onPressed: busy
                    ? null
                    : () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
