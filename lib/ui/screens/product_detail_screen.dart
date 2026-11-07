import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  static const routeName = '/product-detail';

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  int reviewRating = 5;
  int selectedImageIndex = 0;
  bool _addingToCart = false;
  bool _togglingWishlist = false;
  bool _submittingReview = false;
  String? _reportingReviewId;
  final TextEditingController _reviewTitleController = TextEditingController();
  final TextEditingController _reviewCommentController = TextEditingController();
  late Future<ProductDetailModel> _detailFuture;

  @override
  void initState() {
    super.initState();
    final store = context.read<CustomerStore>();
    _detailFuture = store.loadProductDetail(widget.productId);
  }

  @override
  void didUpdateWidget(covariant ProductDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      selectedImageIndex = 0;
      final store = context.read<CustomerStore>();
      _detailFuture = store.loadProductDetail(widget.productId);
    }
  }

  Future<void> _reportReview(ReviewModel review) async {
    final store = context.read<CustomerStore>();
    if (!store.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            store.isArabic
                ? 'يرجى تسجيل الدخول للإبلاغ عن هذه المراجعة.'
                : 'Please sign in to report this review.',
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(store.isArabic ? 'الإبلاغ عن المراجعة' : 'Report review'),
        content: Text(
          store.isArabic
              ? 'هل تريد الإبلاغ عن هذه المراجعة لمراجعتها من قبل فريقنا؟'
              : 'Report this review to our team for moderation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(store.isArabic ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(store.isArabic ? 'إبلاغ' : 'Report'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _reportingReviewId = review.id);
    try {
      await store.reportReview(reviewId: review.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              store.isArabic
                  ? 'شكرًا لك. سيراجع فريقنا هذه المراجعة.'
                  : 'Thanks. Our team will review this content.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _reportingReviewId = null);
    }
  }

  @override
  void dispose() {
    _reviewTitleController.dispose();
    _reviewCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return FutureBuilder<ProductDetailModel>(
      future: _detailFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return CustomerShell(
            title: store.isArabic ? 'تفاصيل المنتج' : 'Product Detail',
            child: const Center(child: Text('Unable to load product')),
          );
        }

        final detail = snapshot.data!;
        final product = detail.product;
        final productImages = product.images;
        final safeImageIndex =
            productImages.isEmpty ? 0 : selectedImageIndex.clamp(0, productImages.length - 1);

        return CustomerShell(
          title: store.isArabic ? 'تفاصيل المنتج' : 'Product Detail',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              FloralSection(
                padding: const EdgeInsets.all(14),
                child: SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: AspectRatio(
                          aspectRatio: 1.12,
                          child: productImages.isNotEmpty
                              ? Image.network(productImages[safeImageIndex], fit: BoxFit.cover)
                              : Container(
                                  color: const Color(0xFFF7F1EC),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_outlined, size: 40),
                                ),
                        ),
                      ),
                      if (productImages.length > 1) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 78,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: productImages.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final isActive = index == safeImageIndex;
                              return GestureDetector(
                                onTap: () => setState(() => selectedImageIndex = index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 78,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isActive
                                          ? AppTheme.accent
                                          : Colors.black.withValues(alpha: 0.08),
                                      width: isActive ? 1.8 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isActive
                                            ? AppTheme.accent.withValues(alpha: 0.16)
                                            : Colors.black.withValues(alpha: 0.04),
                                        blurRadius: isActive ? 16 : 10,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.network(
                                      productImages[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Text(product.categoryName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.gold)),
                      const SizedBox(height: 8),
                      Text(product.name, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('★' * (product.averageRating.round().clamp(1, 5)), style: const TextStyle(color: AppTheme.gold)),
                          const SizedBox(width: 8),
                          Text('(${product.reviewCount} reviews)'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AED ${product.price.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.accent),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.isOutOfStock
                            ? (store.isArabic ? 'غير متوفر حالياً' : 'Out of stock')
                            : (store.isArabic ? '${product.stock} متوفر' : '${product.stock} available'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: product.isOutOfStock ? Colors.red : Colors.green,
                            ),
                      ),
                      if (product.barcode.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${store.isArabic ? 'الباركود' : 'Barcode'}: ${product.barcode}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.gold,
                              ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: _QuantityPicker(
                          quantity: quantity,
                          onDecrement: () => setState(() => quantity = quantity > 1 ? quantity - 1 : 1),
                          onIncrement: () =>
                              setState(() => quantity = quantity < product.stock ? quantity + 1 : quantity),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: product.isOutOfStock || _addingToCart
                              ? null
                              : () async {
                                  if (!store.isAuthenticated) {
                                    if (context.mounted) Navigator.pushNamed(context, '/login');
                                    return;
                                  }
                                  setState(() => _addingToCart = true);
                                  try {
                                    await store.addToCart(productId: product.id, quantity: quantity);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Added to cart')),
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => _addingToCart = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_addingToCart)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              else
                                const Icon(Icons.shopping_cart_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text(store.isArabic ? 'أضف إلى السلة' : 'Add To Cart'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _togglingWishlist
                              ? null
                              : () async {
                                  if (!store.isAuthenticated) {
                                    if (context.mounted) Navigator.pushNamed(context, '/login');
                                    return;
                                  }
                                  setState(() => _togglingWishlist = true);
                                  try {
                                    await store.toggleWishlist(product.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            store.isWishlisted(product.id) ? 'Added to wishlist' : 'Removed from wishlist',
                                          ),
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => _togglingWishlist = false);
                                  }
                                },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_togglingWishlist)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else
                                Icon(
                                  store.isWishlisted(product.id)
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 18,
                                  color: AppTheme.accent,
                                ),
                              const SizedBox(width: 8),
                              Text(
                                store.isWishlisted(product.id)
                                    ? (store.isArabic ? 'تم الحفظ' : 'Saved')
                                    : (store.isArabic ? 'المفضلة' : 'Wishlist'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...[
                        store.isArabic ? 'شحن سريع' : 'Fast dispatch',
                        store.isArabic ? 'دفع آمن' : 'Secure payment',
                        store.isArabic ? 'جودة مضمونة' : 'Quality assured',
                      ].map(
                        (item) => Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                          ),
                          child: Text(item),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.isArabic ? 'الوصف' : 'Description', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 220),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBF8),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.16)),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          product.description.isEmpty ? product.shortDescription : product.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      store.isArabic ? 'مراجعات العملاء (${detail.reviews.length})' : 'Customer Reviews (${detail.reviews.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    if (detail.reviews.isEmpty)
                      Text(store.isArabic ? 'لا توجد مراجعات بعد.' : 'No reviews yet.')
                    else
                      ...detail.reviews.map(
                        (review) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBF8),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(review.author, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text('★' * review.rating, style: const TextStyle(color: AppTheme.gold)),
                                if (review.title.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(review.title, style: Theme.of(context).textTheme.titleMedium),
                                ],
                                const SizedBox(height: 6),
                                Text(review.comment),
                                if (review.id.isNotEmpty)
                                  Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: TextButton.icon(
                                      onPressed: _reportingReviewId == review.id
                                          ? null
                                          : () => _reportReview(review),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF8A7F78),
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      icon: const Icon(Icons.flag_outlined, size: 15),
                                      label: Text(
                                        store.isArabic ? 'الإبلاغ عن المراجعة' : 'Report review',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (store.isAuthenticated) ...[
                      const SizedBox(height: 18),
                      Text(
                        store.isArabic ? 'أضيفي مراجعة' : 'Write a Review',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        initialValue: reviewRating,
                        items: List.generate(
                          5,
                          (index) => DropdownMenuItem(
                            value: 5 - index,
                            child: Text('${5 - index}'),
                          ),
                        ),
                        onChanged: (value) => setState(() => reviewRating = value ?? 5),
                        decoration: InputDecoration(
                          labelText: store.isArabic ? 'التقييم' : 'Rating',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _reviewTitleController,
                        decoration: InputDecoration(
                          labelText: store.isArabic ? 'عنوان المراجعة' : 'Review Title',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _reviewCommentController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: store.isArabic ? 'رأيك في المنتج' : 'Share your experience',
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: _submittingReview
                            ? null
                            : () async {
                                setState(() => _submittingReview = true);
                                try {
                                  await store.submitReview(
                                    productId: product.id,
                                    title: _reviewTitleController.text.trim(),
                                    comment: _reviewCommentController.text.trim(),
                                    rating: reviewRating,
                                  );
                                  setState(() {
                                    _detailFuture = store.loadProductDetail(widget.productId);
                                    _reviewTitleController.clear();
                                    _reviewCommentController.clear();
                                    reviewRating = 5;
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Review submitted')),
                                    );
                                  }
                                } catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => _submittingReview = false);
                                }
                              },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_submittingReview)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            else
                              const Icon(Icons.star_border_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(store.isArabic ? 'إرسال المراجعة' : 'Submit Review'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),
              FutureBuilder<List<ProductModel>>(
                future: _loadRelatedProducts(product),
                builder: (context, relatedSnapshot) {
                  if (relatedSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final products = (relatedSnapshot.data ?? const <ProductModel>[])
                      .where((item) => item.id != product.id)
                      .take(6)
                      .toList();
                  if (products.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.isArabic ? 'منتجات ذات صلة' : 'Related Products',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 320,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final item = products[index];
                            return ProductCardTile(
                              product: item,
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                ProductDetailScreen.routeName,
                                arguments: item.slug,
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemCount: products.length,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<ProductModel>> _loadRelatedProducts(ProductModel product) {
    final store = context.read<CustomerStore>();
    if (product.categoryId.isEmpty) {
      return Future.value(const <ProductModel>[]);
    }
    return store.loadProducts(
      query: {
        'categoryId': product.categoryId,
        'sortBy': 'bestSelling',
      },
    );
  }
}

class _QuantityPicker extends StatelessWidget {
  const _QuantityPicker({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(onPressed: onDecrement, icon: const Icon(Icons.remove_rounded)),
          const SizedBox(width: 2),
          SizedBox(width: 28, child: Text('$quantity', textAlign: TextAlign.center)),
          const SizedBox(width: 2),
          IconButton(onPressed: onIncrement, icon: const Icon(Icons.add_rounded)),
        ],
      ),
    );
  }
}
