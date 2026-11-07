import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'ui/screens/cart_screen.dart';
import 'ui/screens/categories_screen.dart';
import 'ui/screens/checkout_screen.dart';
import 'ui/screens/content_page_screen.dart';
import 'ui/screens/blog_detail_screen.dart';
import 'ui/screens/blog_screen.dart';
import 'ui/screens/forgot_password_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/orders_screen.dart';
import 'ui/screens/order_detail_screen.dart';
import 'ui/screens/privacy_policy_screen.dart';
import 'ui/screens/product_detail_screen.dart';
import 'ui/screens/products_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/register_screen.dart';
import 'ui/screens/reset_password_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/wishlist_screen.dart';

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nature Republic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        '/': (_) => const HomeScreen(),
        '/categories': (_) => const CategoriesScreen(),
        '/products': (_) => const ProductsScreen(),
        '/best-sellers': (_) => const ProductsScreen(bestSellersOnly: true),
        '/blog': (_) => const BlogScreen(),
        '/cart': (_) => const CartScreen(),
        '/checkout': (_) => const CheckoutScreen(),
        '/wishlist': (_) => const WishlistScreen(),
        '/profile': (_) => const ProfileScreen(),
        PrivacyPolicyScreen.routeName: (_) => const PrivacyPolicyScreen(),
        '/orders': (_) => const OrdersScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == ProductsScreen.categoryRouteName) {
          final map = settings.arguments is Map<String, String>
              ? settings.arguments as Map<String, String>
              : const <String, String>{};
          return MaterialPageRoute(
            builder: (_) => ProductsScreen.category(
              categoryId: map['categoryId'] ?? '',
              categoryName: map['categoryName'] ?? '',
            ),
          );
        }
        if (settings.name == ProductDetailScreen.routeName) {
          final productId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: productId),
          );
        }
        if (settings.name == BlogDetailScreen.routeName) {
          final slug = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => BlogDetailScreen(slug: slug),
          );
        }
        if (settings.name == OrderDetailScreen.routeName) {
          final orderId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: orderId),
          );
        }
        if (settings.name == ContentPageScreen.routeName) {
          final slug = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => ContentPageScreen(slug: slug),
          );
        }
        return null;
      },
    );
  }
}
