import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedAddressId;
  final String _paymentMethod = 'stripe';
  bool _submitting = false;
  bool _preparingStripe = false;
  bool _stripeReady = false;
  bool _didInitializeCheckout = false;
  final bool _showStripeHint = false;
  String? _checkoutMessage;
  String? _stripeClientSecret;
  String? _stripeIntentId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitializeCheckout) return;

    final store = context.read<CustomerStore>();
    final addresses = store.user?.addresses ?? const [];
    final defaultAddress = addresses.where((item) => item.isDefault);
    final defaultId = defaultAddress.isNotEmpty ? defaultAddress.first.id : null;
    _selectedAddressId ??= defaultId ?? (addresses.isNotEmpty ? addresses.first.id : null);
    _didInitializeCheckout = true;
    if (_selectedAddressId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        store.loadShippingQuote(_selectedAddressId!);
        _syncPaymentPreparation();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();
    final addresses = store.user?.addresses ?? const [];
    final cart = store.cart;
    final shipping = store.shippingQuote;
    final total = cart.total + (shipping?.shippingAmount ?? 0);
    final canSubmit = !_submitting &&
        !_preparingStripe &&
        _selectedAddressId != null &&
        cart.items.isNotEmpty &&
        (_paymentMethod != 'stripe' || _stripeReady);

    return CustomerShell(
      title: AppText.checkout(store.isArabic),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.confirmOrder(store.isArabic),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(AppText.checkoutCopy(store.isArabic)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppText.shippingAddress(store.isArabic), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (addresses.isEmpty)
                  Text(AppText.addAddressFirst(store.isArabic))
                else
                  RadioGroup<String>(
                    groupValue: _selectedAddressId,
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() {
                        _selectedAddressId = value;
                        _checkoutMessage = null;
                      });
                      await store.loadShippingQuote(value);
                      await _syncPaymentPreparation();
                    },
                    child: Column(
                      children: addresses
                          .map(
                            (address) => RadioListTile<String>(
                              value: address.id,
                              contentPadding: EdgeInsets.zero,
                              title: Text(address.fullName),
                              subtitle: Text('${address.addressLine1}, ${address.city}, ${address.country}'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppText.paymentMethod(store.isArabic), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                RadioGroup<String>(
                  groupValue: _paymentMethod,
                  onChanged: (_) {},
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        value: 'stripe',
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Stripe'),
                        subtitle: Text(AppText.stripeCopy(store.isArabic)),
                      ),
                    ],
                  ),
                ),
                if (_showStripeHint && _paymentMethod == 'stripe') ...[
                  const SizedBox(height: 8),
                  Text(
                    store.isArabic
                        ? 'سيتم فتح نافذة الدفع بالبطاقة عند الضغط على ادفع الآن.'
                        : 'The secure card sheet will open when you tap Pay Now.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (_preparingStripe) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        store.isArabic
                            ? 'جارٍ تجهيز الدفع الآمن...'
                            : 'Preparing secure payment...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
                if (_checkoutMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_checkoutMessage!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppText.orderSummary(store.isArabic), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...cart.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(child: Text('${item.product.name} x${item.quantity}')),
                        Text('AED ${item.lineTotal.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),
                _summaryRow(AppText.subtotal(store.isArabic), cart.subtotal),
                _summaryRow(AppText.discount(store.isArabic), cart.discount),
                _summaryRow(AppText.shipping(store.isArabic), shipping?.shippingAmount ?? 0),
                _summaryRow(AppText.total(store.isArabic), total, isStrong: true),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: !canSubmit
                      ? null
                      : () async {
                          setState(() {
                            _submitting = true;
                            _checkoutMessage = null;
                          });
                          try {
                            final clientSecret = _stripeClientSecret;
                            final fallbackIntentId = _stripeIntentId;
                            if (clientSecret == null || clientSecret.isEmpty) {
                              throw Exception(
                                store.isArabic
                                    ? 'نموذج الدفع غير جاهز بعد. يرجى المحاولة بعد لحظات.'
                                    : 'Stripe payment form is not ready yet.',
                              );
                            }
                            await Stripe.instance.presentPaymentSheet();
                            final paymentIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);

                            if (paymentIntent.status != PaymentIntentsStatus.Succeeded) {
                              throw Exception(
                                store.isArabic
                                    ? 'لم يكتمل الدفع بعد. يرجى المحاولة مرة أخرى.'
                                    : 'Stripe payment is not completed yet.',
                              );
                            }

                            await store.placeOrder(
                              addressId: _selectedAddressId!,
                              paymentMethod: 'stripe',
                              paymentIntentId: paymentIntent.id.isNotEmpty ? paymentIntent.id : fallbackIntentId,
                            );
                            await store.loadCart();
                            await store.loadOrders();
                            _resetStripeState();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppText.paymentSuccess(store.isArabic))),
                              );
                              Navigator.pushNamedAndRemoveUntil(context, '/orders', (_) => false);
                            }
                          } on StripeException catch (error) {
                            if (context.mounted) {
                              final message = error.error.localizedMessage ??
                                  (store.isArabic ? 'تعذر إكمال الدفع عبر Stripe.' : 'Stripe payment could not be completed.');
                              setState(() {
                                _checkoutMessage = message;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                            }
                          } catch (error) {
                            if (context.mounted) {
                              final message = error.toString().replaceFirst('Exception: ', '');
                              setState(() {
                                _checkoutMessage = message;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _submitting = false);
                            }
                          }
                        },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_submitting) ...[
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _submitting
                                ? AppText.processing(store.isArabic)
                                : AppText.payNow(store.isArabic),
                            textAlign: TextAlign.center,
                            textDirection: store.isArabic ? TextDirection.rtl : TextDirection.ltr,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isStrong = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            'AED ${value.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: isStrong ? FontWeight.w700 : FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _syncPaymentPreparation() async {
    final store = context.read<CustomerStore>();

    if (_paymentMethod != 'stripe' || _selectedAddressId == null || store.cart.items.isEmpty) {
      if (mounted) {
        setState(_resetStripeState);
      } else {
        _resetStripeState();
      }
      return;
    }

    setState(() {
      _preparingStripe = true;
      _stripeReady = false;
    });

    try {
      final intent = await store.createStripePaymentIntent(_selectedAddressId!);
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Nature Republic',
          paymentIntentClientSecret: intent.clientSecret,
        ),
      );
      if (!mounted) return;
      setState(() {
        _stripeClientSecret = intent.clientSecret;
        _stripeIntentId = intent.paymentIntentId;
        _stripeReady = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _stripeClientSecret = null;
        _stripeIntentId = null;
        _stripeReady = false;
        _checkoutMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _preparingStripe = false);
      }
    }
  }

  void _resetStripeState() {
    _preparingStripe = false;
    _stripeReady = false;
    _stripeClientSecret = null;
    _stripeIntentId = null;
  }
}
