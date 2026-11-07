import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';
import 'product_detail_screen.dart';
import 'products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _bannerController;
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(viewportFraction: 1);
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();
    final home = store.home;

    return CustomerShell(
      title: 'Nature Republic',
      isBrand: true,
      child: RefreshIndicator(
        onRefresh: store.loadHome,
        child: home == null && store.busy
            ? const Center(child: CircularProgressIndicator())
            : home == null
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.isArabic ? 'تعذر تحميل الصفحة الرئيسية' : 'Unable to load home data',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(store.message ?? (store.isArabic ? 'تحقق من الاتصال وحاول مرة أخرى.' : 'Check the connection and try again.')),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: store.loadHome,
                              child: Text(store.isArabic ? 'إعادة المحاولة' : 'Try Again'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  FloralSection(
                    padding: const EdgeInsets.all(14),
                    child: SurfaceCard(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: _HeroBanner(
                        banners: home.banners,
                        pageController: _bannerController,
                        currentIndex: _bannerIndex,
                        onPageChanged: (index) => setState(() => _bannerIndex = index),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _HomeSection(
                    title: AppText.shopByCategory(store.isArabic),
                    subtitle: AppText.shopByCategoryCopy(store.isArabic),
                    child: _HorizontalRail(
                      height: 340,
                      children: home.categories
                          .map(
                            (category) => Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: CategoryTile(
                                category: category,
                                width: 212,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  ProductsScreen.categoryRouteName,
                                  arguments: {
                                    'categoryId': category.id,
                                    'categoryName': category.name,
                                  },
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _HomeSection(
                    title: AppText.featuredProducts(store.isArabic),
                    subtitle: AppText.featuredProductsCopy(store.isArabic),
                    child: _HorizontalRail(
                      height: 344,
                      children: home.featuredProducts
                          .map(
                            (product) => Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: ProductCardTile(
                                product: product,
                                width: 204,
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
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _HomeSection(
                    title: AppText.topSellingProducts(store.isArabic),
                    subtitle: AppText.topSellingProductsCopy(store.isArabic),
                    child: _HorizontalRail(
                      height: 344,
                      children: home.bestSellingProducts
                          .map(
                            (product) => Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: ProductCardTile(
                                product: product,
                                width: 204,
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
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.banners,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<BannerModel> banners;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();
    final fallback = BannerModel(
      id: 'fallback',
      title: AppText.heroTitle(store.isArabic),
      subtitle: AppText.heroSubtitle(store.isArabic),
      description: AppText.heroDescription(store.isArabic),
      image: '',
    );
    final heroItems = banners.isEmpty ? [fallback] : banners;

    return Column(
      children: [
        SizedBox(
          height: 480,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: heroItems.length,
            itemBuilder: (context, index) {
              final banner = heroItems[index];
              final eyebrow =
                  banner.subtitle.isNotEmpty ? banner.subtitle : AppText.heroSubtitle(store.isArabic);
              final title = banner.title.isNotEmpty ? banner.title : AppText.heroTitle(store.isArabic);
              final description = banner.description.isNotEmpty
                  ? banner.description
                  : AppText.heroDescription(store.isArabic);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.gold,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    eyebrow,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.2,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: banner.image.isNotEmpty
                        ? Image.network(banner.image, fit: BoxFit.cover, width: double.infinity, height: 160)
                        : Container(
                            color: const Color(0xFFF7F1EC),
                            alignment: Alignment.center,
                            height: 160,
                            child: const Icon(Icons.image_outlined, size: 44),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.12,
                          letterSpacing: -0.4,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.muted,
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/products'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        elevation: 6,
                        shadowColor: AppTheme.accent.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppText.shopNow(store.isArabic)),
                          const SizedBox(width: 8),
                          Icon(
                            store.isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (heroItems.length > 1) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              heroItems.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: currentIndex == index ? 26 : 9,
                height: 9,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: currentIndex == index ? AppTheme.accent : AppTheme.gold.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitle(title: title, subtitle: subtitle),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _HorizontalRail extends StatelessWidget {
  const _HorizontalRail({
    required this.children,
    required this.height,
  });

  final List<Widget> children;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: children,
      ),
    );
  }
}
