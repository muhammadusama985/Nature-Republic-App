import 'package:flutter/material.dart';

import '../../core/i18n/app_text.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models.dart';

class FloralSection extends StatelessWidget {
  const FloralSection({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/bg.jpeg'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: padding,
      child: child,
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(title, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }
}

class ProductCardTile extends StatelessWidget {
  const ProductCardTile({
    super.key,
    required this.product,
    required this.onTap,
    this.onQuickAdd,
    this.width = 210,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback? onQuickAdd;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 190 || constraints.maxHeight < 290;
            final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: compact ? 12.5 : 14.5,
                  height: 1.2,
                );
            final priceStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.accent,
                  fontSize: compact ? 12.5 : 14.5,
                );

            return SurfaceCard(
              padding: EdgeInsets.all(compact ? 9 : 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(compact ? 16 : 18),
                    child: AspectRatio(
                      aspectRatio: compact ? 1.28 : 1.08,
                      child: product.images.isNotEmpty
                          ? Image.network(product.images.first, fit: BoxFit.cover)
                          : Container(
                              color: const Color(0xFFF7F1EC),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image_outlined,
                                size: compact ? 28 : 34,
                                color: AppTheme.muted,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: compact ? 6 : 8),
                  Text(
                    product.categoryName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: compact ? 8.5 : 9.5,
                          color: AppTheme.gold,
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.name,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'AED ${product.price.toStringAsFixed(2)}',
                    style: priceStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  if (onQuickAdd != null) ...[
                    SizedBox(height: compact ? 5 : 7),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onQuickAdd,
                        icon: Icon(Icons.add_shopping_cart_rounded, size: compact ? 13 : 15),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            compact ? AppText.cart(Directionality.of(context) == TextDirection.rtl) : AppText.addToCart(Directionality.of(context) == TextDirection.rtl),
                            maxLines: 1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(compact ? 32 : 36),
                          padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 5 : 7),
                          textStyle: TextStyle(fontSize: compact ? 10.5 : 11.5, fontWeight: FontWeight.w600),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    this.width = 220,
  });

  final CategoryModel category;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 1.15,
                  child: category.image.isNotEmpty
                      ? Image.network(category.image, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFFF7F1EC),
                          alignment: Alignment.center,
                          child: const Icon(Icons.category_outlined),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        category.description.trim().isEmpty
                            ? AppText.categoryFallbackCopy(Directionality.of(context) == TextDirection.rtl)
                            : category.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.45),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
