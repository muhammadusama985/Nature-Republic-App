import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../core/theme/app_theme.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const routeName = '/privacy';

  static const String deletionPageUrl =
      'https://www.naturerepublic.ae/account-deletion.html';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();
    final isArabic = store.isArabic;
    final sections = _sections(isArabic);

    return CustomerShell(
      title: AppText.privacyPolicy(isArabic),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          FloralSection(
            padding: const EdgeInsets.all(12),
            child: SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText.privacyPolicy(isArabic),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic
                        ? 'سارية اعتباراً من 5 نوفمبر 2026'
                        : 'Effective 5 November 2026',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  for (final section in sections) ...[
                    Text(
                      section.heading,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      section.body,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                  ],
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBF8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'حذف الحساب' : 'Delete your account',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isArabic
                              ? 'يمكنك حذف حسابك وبياناتك الشخصية من التطبيق عبر: الملف الشخصي ← حذف الحساب. كما يمكنك طلب الحذف عبر صفحة الويب التالية:'
                              : 'You can delete your account and personal data in the app from Profile → Delete Account. You can also request deletion on the web page below:',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        const SelectableText(
                          deletionPageUrl,
                          style: TextStyle(
                            color: AppTheme.accentDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_PolicySection> _sections(bool isArabic) {
    if (isArabic) {
      return const [
        _PolicySection(
          heading: 'من نحن',
          body:
              'يوفر تطبيق Nature Republic تجربة تسوق لمنتجات العناية والجمال في الإمارات العربية المتحدة. نحن مسؤولون عن البيانات الشخصية التي نجمعها من خلال التطبيق.',
        ),
        _PolicySection(
          heading: 'البيانات التي نجمعها',
          body:
              'بيانات الحساب: الاسم الأول واسم العائلة والبريد الإلكتروني ورقم الهاتف وكلمة المرور (مشفرة ولا تُعرض لنا).\n'
              'بيانات التسوق: العناوين المحفوظة والمفضلة وسجل الطلبات والمراجعات التي تكتبينها.\n'
              'بيانات الطلب: المنتجات والكميات والمبالغ وعنوان الشحن ومعلومات التتبع.\n'
              'بيانات الدفع: تتم معالجة الدفع بواسطة Stripe. لا نخزن أرقام البطاقات الكاملة في خوادمنا.\n'
              'بيانات تقنية أساسية: معلومات ضرورية لتشغيل الخدمة وتأمينها واستكشاف الأخطاء.',
        ),
        _PolicySection(
          heading: 'كيف نستخدم البيانات',
          body:
              'لإنشاء حسابك وإدارته، وتنفيذ الطلبات وشحنها، ومعالجة المدفوعات والمرتجعات، والرد على استفساراتك، وتخصيص تجربة التسوق، وحماية الخدمة من الاحتيال وإساءة الاستخدام، والامتثال للقوانين.',
        ),
        _PolicySection(
          heading: 'مشاركة البيانات',
          body:
              'نشارك البيانات فقط مع مقدمي الخدمات الذين نحتاجهم لتشغيل المتجر، مثل Stripe لمعالجة المدفوعات وAramex لشحن الطلبات ومقدمي الاستضافة والبريد الإلكتروني. قد نكشف البيانات إذا طلب منا ذلك القانون أو جهة مختصة. لا نبيع بياناتك الشخصية.',
        ),
        _PolicySection(
          heading: 'الاحتفاظ بالبيانات وحذفها',
          body:
              'نحتفظ ببيانات حسابك إلى أن تطلبي حذفه. عند حذف الحساب نحذف بيانات الحساب والسلة والمفضلة والمراجعات، ونزيل البيانات الشخصية من سجلات الطلبات مع الاحتفاظ بسجلات المعاملات المطلوبة محاسبياً أو قانونياً. قد تستغرق المعالجة الكاملة مدة تصل إلى 30 يوماً.',
        ),
        _PolicySection(
          heading: 'حقوقك',
          body:
              'يمكنك الوصول إلى بياناتك وتصحيحها من صفحة الملف الشخصي، أو حذف حسابك مباشرة من التطبيق أو عبر صفحة الويب المذكورة أدناه. يمكنك أيضاً التواصل معنا لطلب نسخة من بياناتك أو للاعتراض على معالجتها.',
        ),
        _PolicySection(
          heading: 'الأمان',
          body:
              'نستخدم اتصالات مشفرة (HTTPS) وطرق حماية مناسبة لحفظ البيانات. لا يمكن ضمان أمان أي خدمة على الإنترنت بنسبة 100%، لكننا نعمل على حماية بياناتك باستمرار.',
        ),
        _PolicySection(
          heading: 'الأطفال',
          body:
              'التطبيق غير موجه للأطفال دون سن 13 عاماً، ولا نجمع بياناتهم عن قصد. إذا علمت أن طفلاً أنشأ حساباً، تواصلي معنا لحذفه.',
        ),
        _PolicySection(
          heading: 'التغييرات على السياسة',
          body:
              'قد نحدّث هذه السياسة من وقت لآخر. سننشر النسخة المحدثة داخل التطبيق مع تاريخ السريان الجديد.',
        ),
        _PolicySection(
          heading: 'التواصل',
          body:
              'لأي سؤال أو طلب يتعلق بالخصوصية، راسلينا على support@naturerepublic.com.',
        ),
      ];
    }

    return const [
      _PolicySection(
        heading: 'Who we are',
        body:
            'The Nature Republic app provides a beauty and skincare shopping experience in the United Arab Emirates. We are responsible for the personal data collected through this app.',
      ),
      _PolicySection(
        heading: 'Information we collect',
        body:
            'Account data: first name, last name, email address, phone number and password (stored hashed and not visible to us).\n'
            'Shopping data: saved addresses, wishlist, order history and reviews you write.\n'
            'Order data: products, quantities, amounts, shipping address and tracking information.\n'
            'Payment data: payments are processed by Stripe. We do not store full card numbers on our servers.\n'
            'Basic technical data: information needed to operate, secure and troubleshoot the service.',
      ),
      _PolicySection(
        heading: 'How we use information',
        body:
            'To create and manage your account, fulfil and ship orders, process payments and returns, respond to your requests, personalise your shopping experience, prevent fraud and abuse, and comply with the law.',
      ),
      _PolicySection(
        heading: 'How we share information',
        body:
            'We share data only with service providers we need to run the store, such as Stripe for payments, Aramex for shipping, and our hosting and email providers. We may disclose data when required by law or a competent authority. We do not sell your personal data.',
      ),
      _PolicySection(
        heading: 'Retention and deletion',
        body:
            'We keep your account data until you ask us to delete it. When you delete your account we delete your account, cart, wishlist and reviews, and remove personal details from order records while keeping transaction records required for accounting or legal purposes. Complete processing may take up to 30 days.',
      ),
      _PolicySection(
        heading: 'Your rights',
        body:
            'You can access and correct your data from the Profile screen, or delete your account directly in the app or through the web page below. You can also contact us to request a copy of your data or object to its processing.',
      ),
      _PolicySection(
        heading: 'Security',
        body:
            'We use encrypted connections (HTTPS) and appropriate safeguards to protect data. No internet service can be guaranteed to be 100% secure, but we work continuously to protect your information.',
      ),
      _PolicySection(
        heading: 'Children',
        body:
            'The app is not directed to children under 13, and we do not knowingly collect their data. If you believe a child has created an account, contact us so we can delete it.',
      ),
      _PolicySection(
        heading: 'Changes to this policy',
        body:
            'We may update this policy from time to time. We will publish the updated version in the app with a new effective date.',
      ),
      _PolicySection(
        heading: 'Contact',
        body:
            'For any privacy question or request, email us at support@naturerepublic.com.',
      ),
    ];
  }
}

class _PolicySection {
  const _PolicySection({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}
