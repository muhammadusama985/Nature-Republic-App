import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerStore>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return CustomerShell(
      title: store.isArabic ? 'السلة' : 'Cart',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (store.cart.items.isEmpty)
            SurfaceCard(
              child: Text(store.isArabic ? 'سلتك فارغة حالياً.' : 'Your cart is empty right now.'),
            )
          else ...[
            ...store.cart.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 82,
                          height: 82,
                          child: item.product.images.isNotEmpty
                              ? Image.network(item.product.images.first, fit: BoxFit.cover)
                              : const ColoredBox(color: Color(0xFFF7F1EC)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text('AED ${item.product.price.toStringAsFixed(2)}'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: item.quantity > 1
                                      ? () => store.updateCartQuantity(itemId: item.id, quantity: item.quantity - 1)
                                      : null,
                                  icon: const Icon(Icons.remove_rounded),
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  onPressed: () => store.updateCartQuantity(itemId: item.id, quantity: item.quantity + 1),
                                  icon: const Icon(Icons.add_rounded),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => store.removeCartItem(item.id),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await store.clearCart();
                  },
                  icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                  label: Text(store.isArabic ? 'إفراغ السلة' : 'Clear Cart'),
                ),
              ],
            ),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      labelText: store.isArabic ? 'كود الخصم' : 'Coupon Code',
                      suffixIcon: IconButton(
                        onPressed: () async {
                          try {
                            await store.applyCoupon(_couponController.text.trim());
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Coupon applied')),
                              );
                            }
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.local_offer_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (store.cart.discount > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () async {
                          await store.removeCoupon();
                        },
                        child: Text(store.isArabic ? 'إزالة الخصم' : 'Remove Coupon'),
                      ),
                    ),
                  _summaryRow('Subtotal', store.cart.subtotal),
                  _summaryRow('Discount', store.cart.discount),
                  _summaryRow('Total', store.cart.total, isStrong: true),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/checkout'),
                    child: Text(store.isArabic ? 'المتابعة للدفع' : 'Proceed to Checkout'),
                  ),
                ],
              ),
            ),
          ],
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
}
