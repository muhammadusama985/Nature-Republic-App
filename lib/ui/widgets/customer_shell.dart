import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models.dart';
import '../../state/customer_store.dart';
import '../screens/content_page_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/product_detail_screen.dart';
import 'common_widgets.dart';

class CustomerShell extends StatelessWidget {
  const CustomerShell({
    super.key,
    required this.title,
    required this.child,
    this.showHeroBackground = false,
    this.actions = const [],
    this.isBrand = false,
  });

  final String title;
  final Widget child;
  final bool showHeroBackground;
  final List<Widget> actions;
  final bool isBrand;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();
    final theme = Theme.of(context);

    return Directionality(
      textDirection: store.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/logo.jpeg',
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  style: isBrand
                      ? theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                        )
                      : theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/cart'),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_bag_outlined),
                  if (store.cart.totalQuantity > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: AppTheme.accent,
                        child: Text(
                          '${store.cart.totalQuantity}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ...actions,
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
          ],
        ),
        endDrawer: const _ShellDrawer(),
        floatingActionButton: const _ChatbotFab(),
        body: Container(
          decoration: showHeroBackground
              ? const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg.jpeg'),
                    fit: BoxFit.cover,
                  ),
                )
              : null,
          child: SafeArea(
            top: false,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ShellDrawer extends StatelessWidget {
  const _ShellDrawer();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();
    final items = <_DrawerItem>[
      _DrawerItem(
          route: '/',
          icon: Icons.home_outlined,
          label: AppText.home(store.isArabic)),
      _DrawerItem(
          route: '/categories',
          icon: Icons.category_outlined,
          label: AppText.categories(store.isArabic)),
      _DrawerItem(
          route: '/products',
          icon: Icons.grid_view_rounded,
          label: AppText.allProducts(store.isArabic)),
      _DrawerItem(
          route: '/best-sellers',
          icon: Icons.star_border_rounded,
          label: AppText.bestSellers(store.isArabic)),
      _DrawerItem(
          route: '/blog',
          icon: Icons.article_outlined,
          label: AppText.blog(store.isArabic)),
      if (store.isAuthenticated) ...[
        _DrawerItem(
            route: '/wishlist',
            icon: Icons.favorite_border_rounded,
            label: AppText.wishlist(store.isArabic)),
        _DrawerItem(
            route: '/orders',
            icon: Icons.inventory_2_outlined,
            label: AppText.orders(store.isArabic)),
        _DrawerItem(
            route: '/profile',
            icon: Icons.person_outline_rounded,
            label: AppText.profile(store.isArabic)),
      ],
    ];

    return Drawer(
      width: 290,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset('assets/logo.jpeg',
                              width: 44, height: 44, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Nature Republic',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontSize: 17),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/products');
                      },
                      decoration: InputDecoration(
                        hintText: AppText.searchProducts(store.isArabic),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...items.map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -1),
                        leading:
                            Icon(item.icon, color: AppTheme.text, size: 20),
                        title: Text(item.label,
                            style: const TextStyle(fontSize: 14)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, item.route);
                        },
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -1),
                      leading: const Icon(Icons.info_outline_rounded,
                          color: AppTheme.text, size: 20),
                      title: Text(AppText.about(store.isArabic),
                          style: const TextStyle(fontSize: 14)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                            context, ContentPageScreen.routeName,
                            arguments: 'about');
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -1),
                      leading: const Icon(Icons.mail_outline_rounded,
                          color: AppTheme.text, size: 20),
                      title: Text(AppText.contact(store.isArabic),
                          style: const TextStyle(fontSize: 14)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                            context, ContentPageScreen.routeName,
                            arguments: 'contact');
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -1),
                      leading: const Icon(Icons.privacy_tip_outlined,
                          color: AppTheme.text, size: 20),
                      title: Text(AppText.privacyPolicy(store.isArabic),
                          style: const TextStyle(fontSize: 14)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                            context, PrivacyPolicyScreen.routeName);
                      },
                    ),
                    const Divider(height: 28),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -1),
                      leading: const Icon(Icons.language_rounded, size: 20),
                      title: Text(store.isArabic ? 'English' : 'العربية',
                          style: const TextStyle(fontSize: 14)),
                      onTap: () async {
                        await store.setLanguage(store.isArabic ? 'en' : 'ar');
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: !store.isAuthenticated
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(AppText.login(store.isArabic)),
                      )
                    : OutlinedButton(
                        onPressed: () async {
                          await store.logout();
                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (_) => false);
                          }
                        },
                        child: Text(AppText.logout(store.isArabic)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem {
  const _DrawerItem({
    required this.route,
    required this.icon,
    required this.label,
  });

  final String route;
  final IconData icon;
  final String label;
}

class _ChatbotFab extends StatelessWidget {
  const _ChatbotFab();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return FloatingActionButton(
      heroTag: 'customer-chatbot-fab',
      backgroundColor: AppTheme.accent,
      foregroundColor: Colors.white,
      tooltip: AppText.chatAssistant(store.isArabic),
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _ChatbotSheet(),
        );
      },
      child: const Icon(Icons.chat_bubble_outline_rounded),
    );
  }
}

class _ChatbotSheet extends StatefulWidget {
  const _ChatbotSheet();

  @override
  State<_ChatbotSheet> createState() => _ChatbotSheetState();
}

class _ChatbotSheetState extends State<_ChatbotSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ar = context.read<CustomerStore>().isArabic;
      setState(() {
        _messages.add(
          _ChatMessage.bot(
            text: AppText.chatWelcome(ar),
            suggestions: [
              AppText.chatbotSuggestion1(ar),
              AppText.chatbotSuggestion2(ar),
              AppText.chatbotSuggestion3(ar),
            ],
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit([String? value]) async {
    final store = context.read<CustomerStore>();
    final text = (value ?? _controller.text).trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(_ChatMessage.user(text: text));
      _sending = true;
    });
    _controller.clear();

    try {
      final reply = await store.askChatbot(text);
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage.bot(
            text: reply.reply,
            suggestions: reply.suggestions,
            products: reply.products,
            categories: reply.categories,
          ),
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage.bot(
              text: error.toString().replaceFirst('Exception: ', '')),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          12, 12, 12, MediaQuery.of(context).viewInsets.bottom + 12),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.74,
        minChildSize: 0.55,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            AppTheme.accent.withValues(alpha: 0.12),
                        child: const Icon(Icons.chat_bubble_outline_rounded,
                            color: AppTheme.accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppText.chatAssistant(store.isArabic),
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    itemCount: _messages.isEmpty
                        ? 1
                        : _messages.length + (_sending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_messages.isEmpty) {
                        return _EmptyChatState(
                            isArabic: store.isArabic, onSuggestionTap: _submit);
                      }
                      if (_sending && index == _messages.length) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        );
                      }
                      final message = _messages[index];
                      return _ChatBubble(
                        message: message,
                        isArabic: store.isArabic,
                        onSuggestionTap: _submit,
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              hintText: AppText.chatHint(store.isArabic),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _sending ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(78, 48),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          child: Text(AppText.send(store.isArabic)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState({
    required this.isArabic,
    required this.onSuggestionTap,
  });

  final bool isArabic;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      AppText.chatbotSuggestion1(isArabic),
      AppText.chatbotSuggestion2(isArabic),
      AppText.chatbotSuggestion3(isArabic),
    ];

    return SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.chatSuggestionsTitle(isArabic),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(AppText.chatbotEmpty(isArabic)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions
                .map(
                  (label) => ActionChip(
                    label: Text(label),
                    onPressed: () => onSuggestionTap(label),
                    backgroundColor: AppTheme.accent.withValues(alpha: 0.08),
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.isArabic,
    required this.onSuggestionTap,
  });

  final _ChatMessage message;
  final bool isArabic;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final align =
        message.fromUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.fromUser ? AppTheme.accent : const Color(0xFFF8F4EF);
    final textColor = message.fromUser ? Colors.white : AppTheme.text;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(color: textColor, height: 1.45),
            ),
            if (message.suggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.suggestions
                    .map(
                      (suggestion) => ActionChip(
                        label: Text(suggestion),
                        onPressed: () => onSuggestionTap(suggestion),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                            color: AppTheme.accent.withValues(alpha: 0.2)),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (message.products.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                AppText.chatbotProducts(isArabic),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: message.products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final product = message.products[index];
                    return ProductCardTile(
                      product: product,
                      width: 182,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          ProductDetailScreen.routeName,
                          arguments: product.slug,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
            if (message.categories.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                AppText.chatbotCategories(isArabic),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: message.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = message.categories[index];
                    return CategoryTile(
                      category: category,
                      width: 180,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/categories');
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.fromUser,
    this.suggestions = const [],
    this.products = const [],
    this.categories = const [],
  });

  final String text;
  final bool fromUser;
  final List<String> suggestions;
  final List<ProductModel> products;
  final List<CategoryModel> categories;

  factory _ChatMessage.user({required String text}) {
    return _ChatMessage(text: text, fromUser: true);
  }

  factory _ChatMessage.bot({
    required String text,
    List<String> suggestions = const [],
    List<ProductModel> products = const [],
    List<CategoryModel> categories = const [],
  }) {
    return _ChatMessage(
      text: text,
      fromUser: false,
      suggestions: suggestions,
      products: products,
      categories: categories,
    );
  }
}
