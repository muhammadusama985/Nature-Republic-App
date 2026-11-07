import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _message;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return CustomerShell(
      title: AppText.resetPassword(store.isArabic),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.setNewPassword(store.isArabic),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _tokenController,
                  decoration: InputDecoration(labelText: AppText.resetToken(store.isArabic)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: AppText.newPassword(store.isArabic)),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(_message!),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final message = await store.resetPassword(
                      token: _tokenController.text.trim(),
                      password: _passwordController.text.trim(),
                    );
                    setState(() => _message = message);
                  },
                  child: Text(AppText.resetAction(store.isArabic)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
