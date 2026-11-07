import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerStore>().loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return CustomerShell(
      title: store.isArabic ? 'المفضلة' : 'Wishlist',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          SurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.isArabic ? 'قائمة أمنياتك' : 'Your Wishlist',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  store.isArabic ? 'كل المنتجات المحفوظة في مكان واحد.' : 'All saved products in one place.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (store.wishlist.isEmpty)
            SurfaceCard(
              child: Text(store.isArabic ? 'لا توجد عناصر محفوظة.' : 'No saved products yet.'),
            )
          else
            ...store.wishlist.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    ProductDetailScreen.routeName,
                    arguments: product.slug,
                  ),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            width: 88,
                            height: 88,
                            child: product.images.isNotEmpty
                                ? Image.network(product.images.first, fit: BoxFit.cover)
                                : const ColoredBox(color: Color(0xFFF7F1EC)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 6),
                              Text(product.categoryName, style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 6),
                              Text('AED ${product.price.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => store.toggleWishlist(product.id),
                          icon: const Icon(Icons.close_rounded),
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
}
