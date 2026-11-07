import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'state/customer_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = CustomerStore();
  Stripe.publishableKey = AppConfig.stripePublishableKey;

  runApp(
    ChangeNotifierProvider<CustomerStore>.value(
      value: store,
      child: const CustomerApp(),
    ),
  );

  unawaited(_warmUpStripe());
}

Future<void> _warmUpStripe() async {
  try {
    await Stripe.instance.applySettings();
  } catch (_) {
    // Keep the app bootable even if Stripe platform setup is incomplete on a device.
  }
}
