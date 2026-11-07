import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';

class ContentPageScreen extends StatelessWidget {
  const ContentPageScreen({
    super.key,
    required this.slug,
  });

  static const routeName = '/content-page';

  final String slug;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return CustomerShell(
      title: AppText.information(store.isArabic),
      child: FutureBuilder(
        future: store.loadContentPage(slug),
        builder: (context, snapshot) {
          if (!snapshot.hasData &&
              snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text(AppText.pageNotFound(store.isArabic)));
          }
          final page = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              FloralSection(
                padding: const EdgeInsets.all(12),
                child: SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(page.title,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 14),
                      Text(page.content),
                      if (slug == 'contact') ...[
                        const SizedBox(height: 20),
                        _ContactTile(
                          title: AppText.emailSupport(store.isArabic),
                          value: 'support@naturerepublic.com',
                        ),
                        const SizedBox(height: 10),
                        _ContactTile(
                          title: AppText.customerCare(store.isArabic),
                          value: '+971 54 733 0033',
                        ),
                        const SizedBox(height: 10),
                        _ContactTile(
                          title: AppText.workingHours(store.isArabic),
                          value: AppText.workingHoursValue(store.isArabic),
                        ),
                      ],
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

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
