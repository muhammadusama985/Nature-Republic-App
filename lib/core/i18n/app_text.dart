class AppText {
  const AppText._();

  static String home(bool ar) => ar ? 'الرئيسية' : 'Home';
  static String categories(bool ar) => ar ? 'الفئات' : 'Categories';
  static String allProducts(bool ar) => ar ? 'كل المنتجات' : 'All Products';
  static String bestSellers(bool ar) => ar ? 'الأكثر مبيعاً' : 'Best Sellers';
  static String cart(bool ar) => ar ? 'السلة' : 'Cart';
  static String checkout(bool ar) => ar ? 'الدفع' : 'Checkout';
  static String profile(bool ar) => ar ? 'الملف الشخصي' : 'Profile';
  static String orders(bool ar) => ar ? 'الطلبات' : 'Orders';
  static String wishlist(bool ar) => ar ? 'المفضلة' : 'Wishlist';
  static String blog(bool ar) => ar ? 'المدونة' : 'Blog';
  static String information(bool ar) => ar ? 'معلومات' : 'Information';
  static String login(bool ar) => ar ? 'تسجيل الدخول' : 'Login';
  static String register(bool ar) => ar ? 'إنشاء حساب' : 'Register';
  static String logout(bool ar) => ar ? 'تسجيل الخروج' : 'Logout';
  static String forgotPassword(bool ar) =>
      ar ? 'نسيت كلمة المرور' : 'Forgot Password';
  static String resetPassword(bool ar) =>
      ar ? 'إعادة تعيين كلمة المرور' : 'Reset Password';
  static String shopNow(bool ar) => ar ? 'تسوق الآن' : 'Shop Now';
  static String addToCart(bool ar) => ar ? 'أضف إلى السلة' : 'Add To Cart';
  static String saved(bool ar) => ar ? 'تم الحفظ' : 'Saved';
  static String addReview(bool ar) => ar ? 'أضيفي مراجعة' : 'Write a Review';
  static String submitReview(bool ar) =>
      ar ? 'إرسال المراجعة' : 'Submit Review';
  static String beautyJournal(bool ar) =>
      ar ? 'يوميات الجمال' : 'Beauty Journal';
  static String beautyJournalCopy(bool ar) => ar
      ? 'مقالات ومحتوى من نفس مصادر المتجر.'
      : 'Articles and content from the same storefront source.';
  static String relatedProducts(bool ar) =>
      ar ? 'منتجات ذات صلة' : 'Related Products';
  static String description(bool ar) => ar ? 'الوصف' : 'Description';
  static String customerReviews(bool ar, int count) =>
      ar ? 'مراجعات العملاء ($count)' : 'Customer Reviews ($count)';
  static String noReviews(bool ar) =>
      ar ? 'لا توجد مراجعات بعد.' : 'No reviews yet.';
  static String status(bool ar) => ar ? 'الحالة' : 'Status';
  static String total(bool ar) => ar ? 'الإجمالي' : 'Total';
  static String products(bool ar) => ar ? 'المنتجات' : 'Products';
  static String cancel(bool ar) => ar ? 'إلغاء' : 'Cancel';
  static String cancelOrder(bool ar) => ar ? 'إلغاء الطلب' : 'Cancel Order';
  static String shippingAddress(bool ar) =>
      ar ? 'عنوان الشحن' : 'Shipping Address';
  static String paymentMethod(bool ar) => ar ? 'طريقة الدفع' : 'Payment Method';
  static String orderSummary(bool ar) => ar ? 'ملخص الطلب' : 'Order Summary';
  static String subtotal(bool ar) => ar ? 'المجموع الفرعي' : 'Subtotal';
  static String discount(bool ar) => ar ? 'الخصم' : 'Discount';
  static String shipping(bool ar) => ar ? 'الشحن' : 'Shipping';
  static String placeOrder(bool ar) => ar ? 'تأكيد الطلب' : 'Place Order';
  static String payNow(bool ar) => ar ? 'ادفع الآن' : 'Pay Now';
  static String processing(bool ar) =>
      ar ? 'جارٍ المعالجة...' : 'Processing...';
  static String confirmOrder(bool ar) => ar ? 'تأكيد الطلب' : 'Confirm Order';
  static String checkoutCopy(bool ar) => ar
      ? 'اختاري عنوان الشحن وطريقة الدفع لإتمام الطلب.'
      : 'Choose your shipping address and payment method to complete the order.';
  static String shopByCategory(bool ar) =>
      ar ? 'تسوق حسب الفئة' : 'Shop By Category';
  static String shopByCategoryCopy(bool ar) => ar
      ? 'استكشفي الفئات وأنواع المنتجات بنفس ترتيب تجربة الويب.'
      : 'Explore categories created from the admin dashboard and browse products easily.';
  static String categoryFallbackCopy(bool ar) => ar
      ? 'اكتشفي أساسيات الجمال المختارة بعناية لإطلالة يومية واثقة.'
      : 'Explore premium beauty essentials curated for everyday confidence.';
  static String featuredProducts(bool ar) =>
      ar ? 'المنتجات المميزة' : 'Featured Products';
  static String featuredProductsCopy(bool ar) => ar
      ? 'منتجات مختارة بنفس أسلوب عرض الواجهة الحالية.'
      : 'Selected products styled to match the existing storefront experience.';
  static String topSellingProducts(bool ar) =>
      ar ? 'الأكثر مبيعاً' : 'Top Selling Products';
  static String topSellingProductsCopy(bool ar) => ar
      ? 'قائمة سريعة بأفضل المنتجات مبيعاً مثل نسخة الويب.'
      : 'A quick sweep of best-selling items in the same mobile-first style.';
  static String addedToCart(bool ar) =>
      ar ? 'تمت الإضافة إلى السلة' : 'Added to cart';
  static String heroTitle(bool ar) =>
      ar ? 'اكتشفي جمالك الطبيعي' : 'Discover Your Natural Beauty';
  static String heroSubtitle(bool ar) =>
      ar ? 'واجهة الجمال' : 'Beauty Storefront';
  static String heroDescription(bool ar) => ar
      ? 'منتجات عناية ومكياج وعطور بنفس روح المتجر الحالية.'
      : 'Premium beauty products that enhance your natural glow and match the current storefront.';
  static String searchProducts(bool ar) =>
      ar ? 'ابحثي عن المنتجات' : 'Search products';
  static String about(bool ar) => ar ? 'حول' : 'About';
  static String contact(bool ar) => ar ? 'اتصل بنا' : 'Contact';
  static String chatAssistant(bool ar) =>
      ar ? 'مساعد التسوق' : 'Shopping Assistant';
  static String chatWelcome(bool ar) => ar
      ? 'مرحباً! أساعدك في المنتجات والفئات والأسئلة العامة عن المتجر.'
      : 'Hi! I can help with products, categories, and general storefront questions.';
  static String chatHint(bool ar) =>
      ar ? 'اسأل عن المنتجات أو الفئات' : 'Ask about products or categories';
  static String send(bool ar) => ar ? 'إرسال' : 'Send';
  static String chatSuggestionsTitle(bool ar) =>
      ar ? 'اقتراحات سريعة' : 'Quick Suggestions';
  static String chatbotSuggestion1(bool ar) =>
      ar ? 'أرني الأكثر مبيعاً' : 'Show best sellers';
  static String chatbotSuggestion2(bool ar) =>
      ar ? 'أرني المكياج' : 'Show makeup';
  static String chatbotSuggestion3(bool ar) =>
      ar ? 'ما طرق الدفع؟' : 'What payment methods do you offer?';
  static String chatbotEmpty(bool ar) =>
      ar ? 'اكتب رسالتك للبدء.' : 'Type a message to start.';
  static String chatbotProducts(bool ar) =>
      ar ? 'منتجات مقترحة' : 'Suggested Products';
  static String chatbotCategories(bool ar) =>
      ar ? 'فئات مقترحة' : 'Suggested Categories';
  static String createCustomerAccount(bool ar) =>
      ar ? 'إنشاء حساب عميل' : 'Create customer account';
  static String createAccount(bool ar) =>
      ar ? 'إنشاء الحساب' : 'Create Account';
  static String loginToAccount(bool ar) =>
      ar ? 'تسجيل الدخول للحساب' : 'Login to your account';
  static String webAccountHint(bool ar) => ar
      ? 'استخدمي نفس حساب العميل الحالي.'
      : 'Use the same customer account that works on the web app.';
  static String forgotPasswordQuestion(bool ar) =>
      ar ? 'نسيت كلمة المرور؟' : 'Forgot password?';
  static String createNewAccount(bool ar) =>
      ar ? 'إنشاء حساب جديد' : 'Create a new account';
  static String resetAccess(bool ar) => ar ? 'استعادة الوصول' : 'Reset Access';
  static String resetAccessCopy(bool ar) => ar
      ? 'أدخلي بريدك الإلكتروني وسنرسل رابط إعادة التعيين.'
      : 'Enter your email and we will send a reset link.';
  static String sendResetLink(bool ar) =>
      ar ? 'إرسال الرابط' : 'Send Reset Link';
  static String setNewPassword(bool ar) =>
      ar ? 'تعيين كلمة مرور جديدة' : 'Set a New Password';
  static String resetAction(bool ar) => ar ? 'إعادة التعيين' : 'Reset Password';
  static String addAddressFirst(bool ar) => ar
      ? 'أضيفي عنواناً من صفحة الملف الشخصي أولاً.'
      : 'Add an address from the profile screen first.';
  static String cashOnDelivery(bool ar) =>
      ar ? 'الدفع عند الاستلام' : 'Cash on Delivery';
  static String cashOnDeliveryCopy(bool ar) => ar
      ? 'مطابق لخيار الويب الحالي.'
      : 'Matches the current web checkout flow.';
  static String stripeCopy(bool ar) => ar
      ? 'ادفعي ببطاقتك عبر Stripe.'
      : 'Pay securely with your card using Stripe.';
  static String orderNotes(bool ar) => ar ? 'ملاحظات الطلب' : 'Order Notes';
  static String paymentSuccess(bool ar) => ar
      ? 'تم الدفع وإنشاء الطلب بنجاح.'
      : 'Payment completed and order placed successfully.';
  static String orderPlaced(bool ar) =>
      ar ? 'تم إنشاء الطلب بنجاح.' : 'Order placed successfully.';
  static String noOrders(bool ar) =>
      ar ? 'لا توجد طلبات حتى الآن.' : 'No orders yet.';
  static String orderDetail(bool ar) => ar ? 'تفاصيل الطلب' : 'Order Detail';
  static String orderNotFound(bool ar) =>
      ar ? 'الطلب غير موجود' : 'Order not found';
  static String quantityLabel(bool ar, int quantity) =>
      ar ? 'الكمية $quantity' : 'Qty $quantity';
  static String readMore(bool ar) => ar ? 'اقرئي المزيد' : 'Read More';
  static String pageNotFound(bool ar) =>
      ar ? 'الصفحة غير موجودة' : 'Page not found';
  static String emailSupport(bool ar) =>
      ar ? 'البريد الإلكتروني' : 'Email Support';
  static String customerCare(bool ar) => ar ? 'خدمة العملاء' : 'Customer Care';
  static String workingHours(bool ar) => ar ? 'ساعات العمل' : 'Working Hours';
  static String workingHoursValue(bool ar) => ar
      ? 'من الاثنين إلى السبت، 9 صباحاً إلى 6 مساءً'
      : 'Monday to Saturday, 9 AM to 6 PM';
  static String firstName(bool ar) => ar ? 'الاسم الأول' : 'First name';
  static String lastName(bool ar) => ar ? 'اسم العائلة' : 'Last name';
  static String phone(bool ar) => ar ? 'الهاتف' : 'Phone';
  static String password(bool ar) => ar ? 'كلمة المرور' : 'Password';
  static String newPassword(bool ar) =>
      ar ? 'كلمة المرور الجديدة' : 'New password';
  static String resetToken(bool ar) => ar ? 'رمز إعادة التعيين' : 'Reset token';
  static String email(bool ar) => ar ? 'البريد الإلكتروني' : 'Email';
  static String privacyPolicy(bool ar) =>
      ar ? 'سياسة الخصوصية' : 'Privacy Policy';
  static String deleteAccount(bool ar) => ar ? 'حذف الحساب' : 'Delete Account';
  static String deleteAccountWarning(bool ar) => ar
      ? 'سيتم حذف حسابك وبياناتك الشخصية نهائياً. لا يمكن التراجع عن هذا الإجراء.'
      : 'Your account and personal data will be permanently deleted. This action cannot be undone.';
  static String deleteAccountConfirm(bool ar) =>
      ar ? 'حذف الحساب نهائياً' : 'Delete Account Permanently';
  static String accountDeleted(bool ar) => ar
      ? 'تم حذف حسابك وبياناتك الشخصية.'
      : 'Your account and personal data have been deleted.';
  static String dangerZone(bool ar) => ar ? 'منطقة الخطر' : 'Danger Zone';
  static String legal(bool ar) => ar ? 'قانوني' : 'Legal';
}
