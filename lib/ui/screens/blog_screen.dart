import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../data/models.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';
import 'blog_detail_screen.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return CustomerShell(
      title: AppText.blog(store.isArabic),
      child: FutureBuilder<List<BlogPostModel>>(
        future: store.loadBlogPosts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final posts = snapshot.data ?? const <BlogPostModel>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              FloralSection(
                padding: const EdgeInsets.all(12),
                child: SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppText.beautyJournal(store.isArabic),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(AppText.beautyJournalCopy(store.isArabic)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ...posts.map(
                (post) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, BlogDetailScreen.routeName, arguments: post.slug),
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (post.coverImage.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: AspectRatio(
                                aspectRatio: 1.6,
                                child: Image.network(post.coverImage, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                          Text(post.title, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(
                            post.excerpt.isNotEmpty ? post.excerpt : post.content,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppText.readMore(store.isArabic),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFFEC4B8F)),
                          ),
                        ],
                      ),
                    ),
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
