import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';

class BlogDetailScreen extends StatelessWidget {
  const BlogDetailScreen({
    super.key,
    required this.slug,
  });

  static const routeName = '/blog-detail';

  final String slug;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return CustomerShell(
      title: store.isArabic ? 'تفاصيل المقال' : 'Article',
      child: FutureBuilder(
        future: store.loadBlogPost(slug),
        builder: (context, snapshot) {
          if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Blog post not found'));
          }
          final post = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.title, style: Theme.of(context).textTheme.headlineMedium),
                    if (post.coverImage.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.network(post.coverImage, fit: BoxFit.cover),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(post.content),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
