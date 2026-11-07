import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    super.key,
    this.bestSellersOnly = false,
    this.categoryId = '',
    this.categoryName = '',
  });

  const ProductsScreen.category({
    super.key,
    this.bestSellersOnly = false,
    this.categoryId = '',
    this.categoryName = '',
  });

  static const routeName = '/products';
  static const categoryRouteName = '/products/category';

  final bool bestSellersOnly;
  final String categoryId;
  final String categoryName;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late String _selectedCategoryId;
  late String _selectedCategoryName;
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _selectedCategoryName = widget.categoryName;
    _productsFuture = _load();
  }

  Future<List<ProductModel>> _load() {
    final store = context.read<CustomerStore>();
    return store.loadProducts(
      query: {
        if (_selectedCategoryId.isNotEmpty) 'categoryId': _selectedCategoryId,
        'sortBy': widget.bestSellersOnly ? 'bestSelling' : 'newest',
      },
    );
  }

  void _selectCategory(String? categoryId, String categoryName) {
    setState(() {
      _selectedCategoryId = categoryId ?? '';
      _selectedCategoryName = categoryName;
      _productsFuture = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return CustomerShell(
      title: _selectedCategoryName.isNotEmpty
          ? _selectedCategoryName
          : widget.bestSellersOnly
              ? AppText.bestSellers(store.isArabic)
              : AppText.allProducts(store.isArabic),
      child: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.isArabic ? 'تعذر تحميل المنتجات' : 'Unable to load products',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(snapshot.error.toString().replaceFirst('Exception: ', '')),
                    ],
                  ),
                ),
              ],
            );
          }
          final products = snapshot.data ?? const <ProductModel>[];
          final query = _searchController.text.trim().toLowerCase();
          final filtered = query.isEmpty ? products : products.where((item) => item.name.toLowerCase().contains(query)).toList();
          final categories = store.home?.categories ?? const <CategoryModel>[];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              FloralSection(
                padding: const EdgeInsets.all(12),
                child: SurfaceCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search_rounded),
                          hintText: AppText.searchProducts(store.isArabic),
                        ),
                      ),
                      if (categories.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ChoiceChip(
                                label: Text(store.isArabic ? 'الكل' : 'All'),
                                selected: _selectedCategoryId.isEmpty,
                                onSelected: (_) => _selectCategory(null, ''),
                                backgroundColor: const Color(0xFFF7F1EC),
                                selectedColor: AppTheme.accent.withValues(alpha: 0.18),
                                side: BorderSide.none,
                              ),
                              ...categories.map(
                                (category) => Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: ChoiceChip(
                                    label: Text(category.name),
                                    selected: _selectedCategoryId == category.id,
                                    onSelected: (_) => _selectCategory(category.id, category.name),
                                    backgroundColor: const Color(0xFFF7F1EC),
                                    selectedColor: AppTheme.accent.withValues(alpha: 0.18),
                                    side: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.62,
                        ),
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          return ProductCardTile(
                            product: product,
                            width: double.infinity,
                            onTap: () => Navigator.pushNamed(
                              context,
                              ProductDetailScreen.routeName,
                              arguments: product.slug,
                            ),
                            onQuickAdd: store.isAuthenticated
                                ? () async {
                                    await store.addToCart(productId: product.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(AppText.addedToCart(store.isArabic))),
                                      );
                                    }
                                  }
                                : null,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
