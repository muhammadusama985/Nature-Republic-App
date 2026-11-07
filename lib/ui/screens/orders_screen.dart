import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerStore>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return CustomerShell(
      title: AppText.orders(store.isArabic),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (store.orders.isEmpty)
            SurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
              child: Column(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 44, color: AppTheme.gold),
                  const SizedBox(height: 14),
                  Text(
                    AppText.noOrders(store.isArabic),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...store.orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    OrderDetailScreen.routeName,
                    arguments: order.id,
                  ),
                  child: SurfaceCard(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                _orderLabel(order),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _StatusChip(status: order.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.gold),
                            const SizedBox(width: 6),
                            Text(
                              _formatOrderDate(order.createdAt),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                            ),
                          ],
                        ),
                        if (order.items.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _ItemsPreview(items: order.items),
                        ],
                        const SizedBox(height: 14),
                        Divider(height: 1, thickness: 1, color: Colors.black.withValues(alpha: 0.05)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    'AED ',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                                  ),
                                  Text(
                                    order.total.toStringAsFixed(2),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.accent,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (order.status.toLowerCase() == 'pending')
                              OutlinedButton(
                                onPressed: () => store.cancelOrder(order.id),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 40),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(AppText.cancel(store.isArabic)),
                              ),
                            const SizedBox(width: 8),
                            Icon(
                              store.isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                              color: AppTheme.muted,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _orderLabel(OrderModel order) {
    if (order.orderNumber.isNotEmpty) return '#${order.orderNumber}';
    final id = order.id;
    return '#${id.substring(0, id.length > 8 ? 8 : id.length)}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();

    Color background;
    Color foreground;
    String label;
    switch (normalized) {
      case 'pending':
        background = const Color(0xFFFCEFD8);
        foreground = const Color(0xFF9A6B14);
        label = 'Pending';
      case 'processing':
      case 'confirmed':
      case 'accepted':
        background = const Color(0xFFE3EEF9);
        foreground = const Color(0xFF2C5E8C);
        label = 'Processing';
      case 'shipped':
      case 'in_transit':
        background = const Color(0xFFFDE7F1);
        foreground = const Color(0xFFC83373);
        label = 'Shipped';
      case 'delivered':
        background = const Color(0xFFE2F2E4);
        foreground = const Color(0xFF2E6B3A);
        label = 'Delivered';
      case 'cancelled':
      case 'canceled':
        background = const Color(0xFFF1E6E4);
        foreground = const Color(0xFF8C4A3A);
        label = 'Cancelled';
      default:
        background = const Color(0xFFF2ECE7);
        foreground = AppTheme.muted;
        label = status.toUpperCase().isEmpty ? 'Order' : status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ItemsPreview extends StatelessWidget {
  const _ItemsPreview({required this.items});

  final List<CartItemModel> items;

  @override
  Widget build(BuildContext context) {
    final visible = items.take(3).toList();
    final remaining = items.length - visible.length;

    return Row(
      children: [
        for (final item in visible)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 46,
                height: 46,
                child: item.product.images.isNotEmpty
                    ? Image.network(item.product.images.first, fit: BoxFit.cover)
                    : const ColoredBox(
                        color: Color(0xFFF7F1EC),
                        child: Icon(Icons.image_outlined, size: 20, color: AppTheme.muted),
                      ),
              ),
            ),
          ),
        if (remaining > 0)
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF2ECE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$remaining',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.muted),
            ),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            items.first.product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatOrderDate(String value) {
  if (value.isEmpty) return '';
  DateTime? parsed;
  final wcf = RegExp(r'/Date\((-?\d+)(?:[+-]\d{4})?\)/').firstMatch(value);
  if (wcf != null) {
    parsed = DateTime.fromMillisecondsSinceEpoch(int.parse(wcf.group(1)!));
  } else {
    parsed = DateTime.tryParse(value);
  }
  if (parsed == null) return value;
  final local = parsed.toLocal();
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}