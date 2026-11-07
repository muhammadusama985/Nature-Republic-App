import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _message;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return CustomerShell(
      title: AppText.forgotPassword(store.isArabic),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.resetAccess(store.isArabic),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(AppText.resetAccessCopy(store.isArabic)),
                const SizedBox(height: 18),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: AppText.email(store.isArabic)),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(_message!),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final message = await store.forgotPassword(_emailController.text.trim());
                    setState(() => _message = message);
                  },
                  child: Text(AppText.sendResetLink(store.isArabic)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
