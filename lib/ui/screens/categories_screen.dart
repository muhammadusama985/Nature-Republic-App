import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../data/models.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';
import 'products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<CategoryModel>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _load();
  }

  Future<List<CategoryModel>> _load() async {
    final store = context.read<CustomerStore>();
    if (store.home == null) {
      await store.loadHome();
    }
    return store.home?.categories ?? const <CategoryModel>[];
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return CustomerShell(
      title: AppText.categories(store.isArabic),
      child: FutureBuilder<List<CategoryModel>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data ?? const <CategoryModel>[];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              FloralSection(
                padding: const EdgeInsets.all(12),
                child: SurfaceCard(
                  child: Column(
                    children: [
                      SectionTitle(
                        title: AppText.categories(store.isArabic),
                        subtitle: AppText.shopByCategoryCopy(store.isArabic),
                      ),
                      const SizedBox(height: 18),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.68,
                        ),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryTile(
                            category: category,
                            width: double.infinity,
                            onTap: () => Navigator.pushNamed(
                              context,
                              ProductsScreen.categoryRouteName,
                              arguments: {
                                'categoryId': category.id,
                                'categoryName': category.name,
                              },
                            ),
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
