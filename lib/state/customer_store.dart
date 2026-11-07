import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/storage/session_storage.dart';
import '../data/models.dart';
import '../data/services.dart';

class CustomerStore extends ChangeNotifier {
  CustomerStore() {
    _api = ApiClient(onUnauthorized: _refreshSession);
    _service = CustomerApiService(_api);
  }

  late final ApiClient _api;
  late final CustomerApiService _service;

  String _languageCode = 'en';
  String? _accessToken;
  String? _refreshToken;
  UserModel? _user;
  HomePayload? _home;
  CartModel _cart = CartModel.empty();
  List<ProductModel> _wishlist = const [];
  List<OrderModel> _orders = const [];
  ShippingQuoteModel? _shippingQuote;
  String? _message;
  bool _busy = false;

  String get languageCode => _languageCode;
  bool get isArabic => _languageCode == 'ar';
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  UserModel? get user => _user;
  HomePayload? get home => _home;
  CartModel get cart => _cart;
  List<ProductModel> get wishlist => _wishlist;
  List<OrderModel> get orders => _orders;
  ShippingQuoteModel? get shippingQuote => _shippingQuote;
  String? get message => _message;
  bool get busy => _busy;

  Future<void> initialize() async {
    _busy = true;
    notifyListeners();
    try {
      _languageCode = await SessionStorage.getLanguage();
      final session = await SessionStorage.getSession();
      if (session != null) {
        _hydrateSession(session);
        try {
          await refreshCurrentUser();
        } catch (_) {
          await logout(silent: true);
        }
      }
      await loadHome();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    await SessionStorage.saveLanguage(code);
    notifyListeners();
  }

  Future<void> loadHome() async {
    _busy = true;
    notifyListeners();
    try {
      _home = await _service.getHomePayload();
      _message = null;
    } catch (error) {
      _message = error.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<List<ProductModel>> loadProducts(
      {Map<String, String> query = const {}}) {
    return _service.listProducts(query: query);
  }

  Future<List<BlogPostModel>> loadBlogPosts() {
    return _service.getBlogPosts();
  }

  Future<BlogPostModel> loadBlogPost(String slug) {
    return _service.getBlogPost(slug);
  }

  Future<ContentPageModel> loadContentPage(String slug) {
    return _service.getPage(slug);
  }

  Future<ProductDetailModel> loadProductDetail(String slug) {
    return _service.getProductDetail(slug);
  }

  Future<ChatbotReplyModel> askChatbot(String message) {
    return _service.sendChatMessage(message);
  }

  Future<void> submitReview({
    required String productId,
    required String title,
    required String comment,
    required int rating,
  }) async {
    if (_accessToken == null) throw Exception('Please login first.');
    await _service.createReview(
      token: _accessToken!,
      productId: productId,
      title: title,
      comment: comment,
      rating: rating,
    );
  }

  Future<void> reportReview({
    required String reviewId,
    String reason = '',
  }) async {
    if (_accessToken == null) throw Exception('Please login first.');
    await _service.reportReview(
      token: _accessToken!,
      reviewId: reviewId,
      reason: reason,
    );
  }

  Future<void> login({required String email, required String password}) async {
    _busy = true;
    notifyListeners();
    try {
      final session = await _service.login(email: email, password: password);
      _hydrateSession(session);
      await SessionStorage.saveSession(session);
      await refreshCurrentUser();
      await Future.wait([loadCart(), loadWishlist(), loadOrders()]);
      _message = null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    _busy = true;
    notifyListeners();
    try {
      final session = await _service.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
      );
      _hydrateSession(session);
      await SessionStorage.saveSession(session);
      await refreshCurrentUser();
      _message = null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<String> forgotPassword(String email) {
    return _service.forgotPassword(email);
  }

  Future<String> resetPassword({
    required String token,
    required String password,
  }) {
    return _service.resetPassword(token: token, password: password);
  }

  Future<void> refreshCurrentUser() async {
    if (_accessToken == null) return;
    _user = await _service.getCurrentUser(_accessToken!);
    notifyListeners();
  }

  Future<void> loadCart() async {
    if (_accessToken == null) return;
    _cart = await _service.getCart(_accessToken!);
    notifyListeners();
  }

  Future<void> addToCart({required String productId, int quantity = 1}) async {
    if (_accessToken == null) throw Exception('Please login first.');
    _cart = await _service.addCartItem(
        token: _accessToken!, productId: productId, quantity: quantity);
    notifyListeners();
  }

  Future<void> updateCartQuantity(
      {required String itemId, required int quantity}) async {
    if (_accessToken == null) return;
    _cart = await _service.updateCartItem(
        token: _accessToken!, itemId: itemId, quantity: quantity);
    notifyListeners();
  }

  Future<void> removeCartItem(String itemId) async {
    if (_accessToken == null) return;
    _cart = await _service.removeCartItem(token: _accessToken!, itemId: itemId);
    notifyListeners();
  }

  Future<void> clearCart() async {
    if (_accessToken == null) return;
    _cart = await _service.clearCart(token: _accessToken!);
    notifyListeners();
  }

  Future<void> applyCoupon(String code) async {
    if (_accessToken == null) return;
    _cart = await _service.applyCoupon(
      token: _accessToken!,
      code: code,
      subtotal: _cart.subtotal,
    );
    notifyListeners();
  }

  Future<void> removeCoupon() async {
    if (_accessToken == null) return;
    _cart = await _service.removeCoupon(token: _accessToken!);
    notifyListeners();
  }

  Future<void> loadWishlist() async {
    if (_accessToken == null) return;
    _wishlist = await _service.getWishlist(_accessToken!);
    notifyListeners();
  }

  bool isWishlisted(String productId) =>
      _wishlist.any((item) => item.id == productId);

  Future<void> toggleWishlist(String productId) async {
    if (_accessToken == null) throw Exception('Please login first.');
    if (isWishlisted(productId)) {
      _wishlist = await _service.removeWishlistItem(
          token: _accessToken!, productId: productId);
    } else {
      _wishlist = await _service.addWishlistItem(
          token: _accessToken!, productId: productId);
    }
    notifyListeners();
  }

  Future<void> loadOrders() async {
    if (_accessToken == null) return;
    _orders = await _service.getOrders(_accessToken!);
    notifyListeners();
  }

  Future<OrderModel> loadOrder(String orderId) async {
    if (_accessToken == null) throw Exception('Please login first.');
    final order =
        await _service.getOrder(token: _accessToken!, orderId: orderId);
    _upsertOrder(order);
    return order;
  }

  Future<void> cancelOrder(String orderId) async {
    if (_accessToken == null) return;
    final updated =
        await _service.cancelOrder(token: _accessToken!, orderId: orderId);
    _orders = _orders
        .map((order) => order.id == updated.id ? updated : order)
        .toList();
    notifyListeners();
  }

  Future<OrderTrackingResult> trackShipment(String orderId) async {
    if (_accessToken == null) throw Exception('Please login first.');
    final result = await _service.trackOrderShipment(
        token: _accessToken!, orderId: orderId);
    _upsertOrder(result.order);
    return result;
  }

  Future<OrderTrackingResult> trackReturn(String orderId) async {
    if (_accessToken == null) throw Exception('Please login first.');
    final result = await _service.trackOrderReturnShipment(
        token: _accessToken!, orderId: orderId);
    _upsertOrder(result.order);
    return result;
  }

  Future<void> requestReturn({
    required String orderId,
    required String returnReason,
    String? returnDetails,
  }) async {
    if (_accessToken == null) throw Exception('Please login first.');
    final updated = await _service.requestOrderReturn(
      token: _accessToken!,
      orderId: orderId,
      returnReason: returnReason,
      returnDetails: returnDetails,
    );
    _upsertOrder(updated);
  }

  void _upsertOrder(OrderModel order) {
    final index = _orders.indexWhere((item) => item.id == order.id);
    if (index == -1) {
      _orders = [..._orders, order];
    } else {
      _orders = [..._orders]..[index] = order;
    }
    notifyListeners();
  }

  Future<void> saveProfile(
      {required String firstName,
      required String lastName,
      required String phone}) async {
    if (_accessToken == null) return;
    _user = await _service.updateProfile(
      token: _accessToken!,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );
    notifyListeners();
  }

  Future<void> addAddress(Map<String, dynamic> payload) async {
    if (_accessToken == null || _user == null) return;
    final addresses =
        await _service.addAddress(token: _accessToken!, payload: payload);
    _user = UserModel(
      id: _user!.id,
      firstName: _user!.firstName,
      lastName: _user!.lastName,
      email: _user!.email,
      phone: _user!.phone,
      addresses: addresses,
    );
    notifyListeners();
  }

  Future<void> deleteAddress(String addressId) async {
    if (_accessToken == null || _user == null) return;
    final addresses = await _service.removeAddress(
        token: _accessToken!, addressId: addressId);
    _user = UserModel(
      id: _user!.id,
      firstName: _user!.firstName,
      lastName: _user!.lastName,
      email: _user!.email,
      phone: _user!.phone,
      addresses: addresses,
    );
    notifyListeners();
  }

  Future<void> loadShippingQuote(String addressId) async {
    if (_accessToken == null) return;
    try {
      _shippingQuote = await _service.getShippingQuote(
          token: _accessToken!, addressId: addressId);
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      if (message.toLowerCase().contains('cart is empty')) {
        _shippingQuote = null;
      } else {
        rethrow;
      }
    }
    notifyListeners();
  }

  Future<OrderModel> placeOrder({
    required String addressId,
    required String paymentMethod,
    String? paymentIntentId,
    String? notes,
  }) async {
    if (_accessToken == null) throw Exception('Please login first.');
    final order = await _service.createOrder(
      token: _accessToken!,
      addressId: addressId,
      paymentMethod: paymentMethod,
      paymentIntentId: paymentIntentId,
      notes: notes,
    );
    _cart = CartModel.empty();
    await loadOrders();
    notifyListeners();
    return order;
  }

  Future<StripePaymentIntentModel> createStripePaymentIntent(
      String addressId) async {
    if (_accessToken == null) throw Exception('Please login first.');
    return _service.createStripePaymentIntent(
      token: _accessToken!,
      addressId: addressId,
    );
  }

  Future<String> deleteAccount() async {
    if (_accessToken == null) throw Exception('Please login first.');
    final message = await _service.deleteAccount(token: _accessToken!);
    await logout(silent: true);
    return message;
  }

  Future<void> logout({bool silent = false}) async {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    _cart = CartModel.empty();
    _wishlist = const [];
    _orders = const [];
    await SessionStorage.clearSession();
    if (!silent) _message = 'Logged out';
    notifyListeners();
  }

  Future<String?> _refreshSession() async {
    if (_refreshToken == null) return null;
    try {
      final session = await _service.refreshSession(_refreshToken!);
      _hydrateSession(session);
      await SessionStorage.saveSession(session);
      notifyListeners();
      return _accessToken;
    } catch (_) {
      await logout(silent: true);
      return null;
    }
  }

  void _hydrateSession(Map<String, dynamic> session) {
    _accessToken = session['accessToken']?.toString();
    _refreshToken = session['refreshToken']?.toString();
    final userPayload = session['user'];
    if (userPayload is Map<String, dynamic>) {
      _user = UserModel.fromJson(userPayload);
    }
  }
}
