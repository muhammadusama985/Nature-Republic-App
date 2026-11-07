import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return CustomerShell(
      title: AppText.register(store.isArabic),
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
                    AppText.createCustomerAccount(store.isArabic),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(labelText: AppText.firstName(store.isArabic)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(labelText: AppText.lastName(store.isArabic)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: AppText.email(store.isArabic)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: AppText.phone(store.isArabic)),
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
                              await store.register(
                                firstName: _firstNameController.text.trim(),
                                lastName: _lastNameController.text.trim(),
                                email: _emailController.text.trim(),
                                phone: _phoneController.text.trim(),
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
                    child: Text(AppText.createAccount(store.isArabic)),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: Text(AppText.login(store.isArabic)),
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
