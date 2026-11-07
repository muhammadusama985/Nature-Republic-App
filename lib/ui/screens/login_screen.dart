import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return CustomerShell(
      title: AppText.login(store.isArabic),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppText.loginToAccount(store.isArabic),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppText.webAccountHint(store.isArabic),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: AppText.email(store.isArabic)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: AppText.password(store.isArabic)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: store.busy
                        ? null
                        : () async {
                            try {
                              await store.login(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                              }
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
                                );
                              }
                            }
                          },
                    child: Text(AppText.login(store.isArabic)),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                      child: Text(AppText.forgotPasswordQuestion(store.isArabic)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: Text(AppText.createNewAccount(store.isArabic)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
