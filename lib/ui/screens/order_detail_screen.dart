import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../data/models.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  static const routeName = '/order-detail';

  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  TrackingResultModel? _shipmentTracking;
  TrackingResultModel? _returnTracking;
  bool _trackingShipment = false;
  bool _trackingReturn = false;
  bool _loadingOrder = false;
  String? _trackingError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureOrder());
  }

  Future<void> _ensureOrder() async {
    final store = context.read<CustomerStore>();
    final exists = store.orders.any((item) => item.id == widget.orderId);
    if (exists || !mounted) return;
    try {
      if (mounted) setState(() => _loadingOrder = true);
      await store.loadOrder(widget.orderId);
    } catch (_) {
      // The screen renders its "Order not found" state instead.
    } finally {
      if (mounted) setState(() => _loadingOrder = false);
    }
  }

  OrderModel? _findOrder(BuildContext context) {
    final store = context.read<CustomerStore>();
    final matches = store.orders.where((item) => item.id == widget.orderId);
    return matches.isNotEmpty ? matches.first : null;
  }

  Future<void> _trackShipment(CustomerStore store) async {
    setState(() {
      _trackingShipment = true;
      _trackingError = null;
    });
    try {
      final result = await store.trackShipment(widget.orderId);
      if (!mounted) return;
      setState(() => _shipmentTracking = result.tracking);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _trackingError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _trackingShipment = false);
    }
  }

  Future<void> _trackReturn(CustomerStore store) async {
    setState(() {
      _trackingReturn = true;
      _trackingError = null;
    });
    try {
      final result = await store.trackReturn(widget.orderId);
      if (!mounted) return;
      setState(() => _returnTracking = result.tracking);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _trackingError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _trackingReturn = false);
    }
  }

  Future<void> _openReturnRequest(CustomerStore store, OrderModel order) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _RequestReturnDialog(order: order),
    );
    if (result == null || !mounted) return;
    try {
      await store.requestReturn(
        orderId: order.id,
        returnReason: result['returnReason'] ?? '',
        returnDetails: result['returnDetails'],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            store.isArabic
                ? 'تم إرسال طلب الإرجاع. سيراجعه فريقنا ويجمع الطرد من عنوانك.'
                : 'Return request submitted successfully. Our team will review it and arrange a pickup.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();
    final order = _findOrder(context);

    if (order == null) {
      return CustomerShell(
        title: AppText.orderDetail(store.isArabic),
        child: _loadingOrder
            ? const Center(child: CircularProgressIndicator())
            : Center(child: Text(AppText.orderNotFound(store.isArabic))),
      );
    }

    final displayNumber = order.orderNumber.isEmpty
        ? '#${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}'
        : '#${order.orderNumber}';

    return CustomerShell(
      title: AppText.orderDetail(store.isArabic),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          FloralSection(
            padding: const EdgeInsets.all(12),
            child: SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayNumber,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(_formatTimestamp(order.createdAt)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoBox(
                          title: AppText.status(store.isArabic),
                          value: order.status.toUpperCase(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoBox(
                          title: AppText.paymentMethod(store.isArabic),
                          value: _paymentSummary(order),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoBox(
                          title: AppText.shipping(store.isArabic),
                          value: _shippingSummary(order),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoBox(
                          title: AppText.total(store.isArabic),
                          value: 'AED ${order.total.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                  if (order.notes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _InfoBox(
                      title: AppText.orderNotes(store.isArabic),
                      value: order.notes,
                    ),
                  ],
                  if (order.shippingAddress != null) ...[
                    const SizedBox(height: 10),
                    _InfoBox(
                      title: AppText.shippingAddress(store.isArabic),
                      value: _addressSummary(order.shippingAddress!),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.products(store.isArabic),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            width: 70,
                            height: 70,
                            child: item.product.images.isNotEmpty
                                ? Image.network(item.product.images.first, fit: BoxFit.cover)
                                : const ColoredBox(color: Color(0xFFF7F1EC)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(AppText.quantityLabel(store.isArabic, item.quantity)),
                            ],
                          ),
                        ),
                        Text('AED ${item.lineTotal.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (order.status.toLowerCase() == 'pending')
                  OutlinedButton(
                    onPressed: () => store.cancelOrder(order.id),
                    child: Text(AppText.cancelOrder(store.isArabic)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _TrackingCard(
            tracking: _shipmentTracking,
            isLoading: _trackingShipment,
            error: _trackingError,
            orderIdLabel: order.trackingNumber,
            isReturn: false,
            storeIsArabic: store.isArabic,
            onTrack: _trackingShipment ? null : () => _trackShipment(store),
          ),
          if (order.hasActiveReturn) ...[
            const SizedBox(height: 14),
            _ReturnStatusCard(
              order: order,
              tracking: _returnTracking,
              isLoading: _trackingReturn,
              error: _trackingError,
              storeIsArabic: store.isArabic,
              onTrackReturn: order.returnTrackingNumber.isNotEmpty && !_trackingReturn
                  ? () => _trackReturn(store)
                  : null,
            ),
          ],
          if (!order.hasActiveReturn && order.canRequestReturn) ...[
            const SizedBox(height: 14),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.isArabic ? 'تحتاجين إلى إرجاع؟' : 'Need to Return?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    store.isArabic
                        ? 'يمكنك طلب الإرجاع بعد أن يسلم Aramex طلبك. أخبرينا بالسبب وسيقوم فريقنا بمراجعته.'
                        : 'You can request a return once Aramex has delivered your order. Tell us the reason and our team will review it.',
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: () => _openReturnRequest(store, order),
                    child: Text(store.isArabic ? 'طلب الإرجاع' : 'Request Return'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _paymentSummary(OrderModel order) {
    final method = order.paymentMethod.toUpperCase();
    if (order.paymentStatus.isNotEmpty) return '$method - ${order.paymentStatus}';
    return method;
  }

  String _shippingSummary(OrderModel order) {
    if (order.isDelivered) return 'DELIVERED';
    if (order.status.toLowerCase() == 'cancelled') return 'CANCELLED';
    if (order.trackingNumber.isNotEmpty) return 'IN TRANSIT';
    return order.shippingStatus.isEmpty ? 'PENDING' : order.shippingStatus.toUpperCase();
  }

  String _addressSummary(AddressModel address) {
    final parts = <String>[
      address.fullName,
      address.addressLine1,
      if (address.addressLine2.isNotEmpty) address.addressLine2,
      if (address.city.isNotEmpty) address.city,
      if (address.country.isNotEmpty) address.country,
    ];
    return parts.where((item) => item.isNotEmpty).join(', ');
  }
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard({
    required this.tracking,
    required this.isLoading,
    required this.error,
    required this.orderIdLabel,
    required this.isReturn,
    required this.storeIsArabic,
    required this.onTrack,
  });

  final TrackingResultModel? tracking;
  final bool isLoading;
  final String? error;
  final String orderIdLabel;
  final bool isReturn;
  final bool storeIsArabic;
  final VoidCallback? onTrack;

  @override
  Widget build(BuildContext context) {
    final result = tracking;
    final events = result?.events ?? const <TrackingEventModel>[];
    final sorted = List<TrackingEventModel>.from(events)
      ..sort((a, b) => _eventTime(b).compareTo(_eventTime(a)));

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  storeIsArabic
                      ? (isReturn ? 'تتبع الإرجاع - Aramex' : 'تتبع الشحنة - Aramex')
                      : (isReturn ? 'Aramex Return Tracking' : 'Aramex Tracking'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: ElevatedButton(
                  onPressed: isLoading ? null : onTrack,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(88, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(storeIsArabic ? 'تتبع' : 'Track'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if ((result?.shipmentNumber ?? orderIdLabel).isNotEmpty)
            Text(
              '${storeIsArabic ? 'رقم التتبع' : 'Tracking number'} ${result?.shipmentNumber ?? orderIdLabel}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          if ((result?.shipmentNumber ?? orderIdLabel).isEmpty && !isLoading) ...[
            const SizedBox(height: 8),
            Text(
              storeIsArabic
                  ? 'يتم إنشاء رقم تتبع Aramex تلقائياً بمجرد تأكيد الدفع.'
                  : 'The Aramex tracking number is created automatically once your payment is confirmed.',
            ),
          ],
          if (error != null && error!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
          if (result?.hasErrors == true && (result?.errorMessage ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(result!.errorMessage),
          ],
          if (result != null && !result.hasErrors && sorted.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              storeIsArabic
                  ? 'لا توجد أحداث تتبع مسجلة لهذه الشحنة بعد.'
                  : 'No tracking events have been recorded for this shipment yet.',
            ),
          ],
          if (sorted.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...sorted.map(
              (event) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.statusText.isNotEmpty ? event.statusText : 'Status update',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTrackingMoment(event),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (event.location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(event.location),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReturnStatusCard extends StatelessWidget {
  const _ReturnStatusCard({
    required this.order,
    required this.tracking,
    required this.isLoading,
    required this.error,
    required this.storeIsArabic,
    required this.onTrackReturn,
  });

  final OrderModel order;
  final TrackingResultModel? tracking;
  final bool isLoading;
  final String? error;
  final bool storeIsArabic;
  final VoidCallback? onTrackReturn;

  @override
  Widget build(BuildContext context) {
    final result = tracking;
    final events = result?.events ?? const <TrackingEventModel>[];
    final sorted = List<TrackingEventModel>.from(events)
      ..sort((a, b) => _eventTime(b).compareTo(_eventTime(a)));

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            storeIsArabic ? 'حالة الإرجاع' : 'Return Status',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          _ReturnLine(storeIsArabic: storeIsArabic, label: 'Status', value: order.returnStatus.toUpperCase()),
          if (order.returnReason.isNotEmpty)
            _ReturnLine(storeIsArabic: storeIsArabic, label: 'Reason', value: order.returnReason),
          if (order.returnDetails.isNotEmpty)
            _ReturnLine(storeIsArabic: storeIsArabic, label: 'Details', value: order.returnDetails),
          if (order.returnTrackingNumber.isNotEmpty) ...[
            _ReturnLine(
              storeIsArabic: storeIsArabic,
              label: 'Return Tracking',
              value: order.returnTrackingNumber,
            ),
            if (onTrackReturn != null) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: isLoading ? null : onTrackReturn,
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(storeIsArabic ? 'تتبع الإرجاع' : 'Track Return'),
                ),
              ),
            ],
          ],
          if (order.returnResolutionNote.isNotEmpty)
            _ReturnLine(storeIsArabic: storeIsArabic, label: 'Admin Note', value: order.returnResolutionNote),
          if (error != null && error!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
          if (order.returnStatus == 'refunded' || order.returnStatus == 'completed') ...[
            const SizedBox(height: 8),
            Text(
              storeIsArabic
                  ? 'تم رد الدفع تلقائياً إلى طريقة الدفع الأصلية المستخدمة لهذا الطلب.'
                  : 'This payment has been refunded automatically to the original payment method used for this order.',
            ),
          ],
          if (sorted.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...sorted.map(
              (event) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.statusText.isNotEmpty ? event.statusText : 'Status update',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTrackingMoment(event),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (event.location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(event.location),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReturnLine extends StatelessWidget {
  const _ReturnLine({
    required this.storeIsArabic,
    required this.label,
    required this.value,
  });

  final bool storeIsArabic;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _RequestReturnDialog extends StatefulWidget {
  const _RequestReturnDialog({required this.order});

  final OrderModel order;

  @override
  State<_RequestReturnDialog> createState() => _RequestReturnDialogState();
}

class _RequestReturnDialogState extends State<_RequestReturnDialog> {
  static const _reasons = [
    'Wrong item received',
    'Item defective/damaged',
    'Item not as described',
    'Changed my mind',
    'Wrong size',
    'Quality not as expected',
    'Other',
  ];

  String _reason = '';
  final TextEditingController _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return AlertDialog(
      title: Text(store.isArabic ? 'طلب الإرجاع' : 'Request Return'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(store.isArabic ? 'سبب الإرجاع *' : 'Return Reason *'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _reason.isEmpty ? null : _reason,
              hint: Text(store.isArabic ? 'اختر سبباً' : 'Select a reason'),
              items: _reasons
                  .map(
                    (reason) => DropdownMenuItem<String>(
                      value: reason,
                      child: Text(reason),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _reason = value ?? ''),
              decoration: const InputDecoration(isDense: true),
            ),
            const SizedBox(height: 14),
            Text(store.isArabic ? 'تفاصيل إضافية' : 'Additional Details'),
            const SizedBox(height: 8),
            TextField(
              controller: _detailsController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: store.isArabic
                    ? 'أضيفي أي تفاصيل إضافية حول طلب الإرجاع...'
                    : 'Provide any additional details about your return...',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              store.isArabic
                  ? 'للمدفوعات عبر Stripe، سيتم رد المبلغ تلقائياً إلى طريقة الدفع الأصلية. يحتاج طلبك إلى موافقة الإدارة.'
                  : 'For Stripe payments, the refund will be automatically processed to your original payment method. Your request needs admin approval.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppText.cancel(store.isArabic)),
        ),
        FilledButton(
          onPressed: _reason.trim().isEmpty
              ? null
              : () => Navigator.pop(context, {
                  'returnReason': _reason.trim(),
                  'returnDetails': _detailsController.text.trim(),
                }),
          child: Text(
            store.isArabic ? 'إرسال طلب الإرجاع' : 'Submit Return Request',
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

DateTime? _parseTime(String value) {
  if (value.isEmpty) return null;
  final wcf = RegExp(r'/Date\((-?\d+)(?:[+-]\d{4})?\)/').firstMatch(value);
  if (wcf != null) {
    final parsed = DateTime.fromMillisecondsSinceEpoch(int.parse(wcf.group(1)!));
    return parsed;
  }
  return DateTime.tryParse(value);
}

int _eventTime(TrackingEventModel event) =>
    _parseTime(event.updateDateTime)?.millisecondsSinceEpoch ?? 0;

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatTimestamp(String value) {
  if (value.isEmpty) return '';
  final parsed = _parseTime(value);
  if (parsed == null) return value;
  return _formatDateTime(parsed.toLocal());
}

String _formatDateTime(DateTime parsed) {
  final hour = parsed.hour.toString().padLeft(2, '0');
  final minute = parsed.minute.toString().padLeft(2, '0');
  return '${parsed.day} ${_months[parsed.month - 1]} ${parsed.year}, $hour:$minute';
}

String _formatTrackingMoment(TrackingEventModel event) {
  final combined = [
    if (event.eventDate.isNotEmpty) event.eventDate,
    if (event.eventTime.isNotEmpty) event.eventTime,
  ].join('T');
  final parsed = _parseTime(event.updateDateTime) ??
      (combined.isNotEmpty ? _parseTime(combined) : null) ??
      (event.eventDate.isNotEmpty ? _parseTime(event.eventDate) : null);
  if (parsed != null) return _formatDateTime(parsed.toLocal());
  return [event.updateDateTime, event.eventDate].where((item) => item.isNotEmpty).join(' ');
}