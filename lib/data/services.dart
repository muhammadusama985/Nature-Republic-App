import '../core/network/api_client.dart';
import 'models.dart';

class CustomerApiService {
  CustomerApiService(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final payload = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password, 'portal': 'customer'},
      allowRefresh: false,
    ) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final payload = await _api.post(
      '/auth/register',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phone': phone,
      },
      allowRefresh: false,
    ) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refreshSession(String refreshToken) async {
    final payload = await _api.post(
      '/auth/refresh',
      body: {'refreshToken': refreshToken, 'portal': 'customer'},
      allowRefresh: false,
    ) as Map<String, dynamic>;
    return payload['data'] as Map<String, dynamic>;
  }

  Future<String> forgotPassword(String email) async {
    final payload = await _api.post(
      '/auth/forgot-password',
      body: {'email': email},
      allowRefresh: false,
    ) as Map<String, dynamic>;
    return payload['message']?.toString() ?? 'Reset link sent.';
  }

  Future<String> resetPassword({
    required String token,
    required String password,
  }) async {
    final payload = await _api.post(
      '/auth/reset-password',
      body: {'token': token, 'password': password},
      allowRefresh: false,
    ) as Map<String, dynamic>;
    return payload['message']?.toString() ?? 'Password reset successfully.';
  }

  Future<UserModel> getCurrentUser(String token) async {
    final payload =
        await _api.get('/auth/me', token: token) as Map<String, dynamic>;
    return UserModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<HomePayload> getHomePayload() async {
    final payload = await _api.get('/storefront/home') as Map<String, dynamic>;
    return HomePayload.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<ChatbotReplyModel> sendChatMessage(String message) async {
    final payload = await _api.post(
      '/chatbot',
      body: {'message': message},
      allowRefresh: false,
    ) as Map<String, dynamic>;
    return ChatbotReplyModel.fromJson(payload);
  }

  Future<List<BlogPostModel>> getBlogPosts() async {
    final payload = await _api.get('/content/blog') as Map<String, dynamic>;
    return (payload['data'] as List<dynamic>? ?? const [])
        .map((item) => BlogPostModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BlogPostModel> getBlogPost(String slug) async {
    final payload =
        await _api.get('/content/blog/$slug') as Map<String, dynamic>;
    return BlogPostModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<ContentPageModel> getPage(String slug) async {
    final payload =
        await _api.get('/content/pages/$slug') as Map<String, dynamic>;
    return ContentPageModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<List<ProductModel>> listProducts(
      {Map<String, String> query = const {}}) async {
    final queryString = query.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) =>
            '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}')
        .join('&');
    final suffix = queryString.isEmpty ? '' : '?$queryString';
    final payload = await _api.get('/products$suffix') as Map<String, dynamic>;
    return (payload['data'] as List<dynamic>? ?? const [])
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ProductDetailModel> getProductDetail(String slug) async {
    final payload = await _api.get('/products/$slug') as Map<String, dynamic>;
    return ProductDetailModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<void> createReview({
    required String token,
    required String productId,
    required String title,
    required String comment,
    required int rating,
  }) async {
    await _api.post(
      '/reviews',
      token: token,
      body: {
        'productId': productId,
        'title': title,
        'comment': comment,
        'rating': rating,
      },
    );
  }

  Future<void> reportReview({
    required String token,
    required String reviewId,
    String reason = '',
  }) async {
    await _api.post(
      '/reviews/$reviewId/report',
      token: token,
      body: {'reason': reason},
    );
  }

  Future<CartModel> getCart(String token) async {
    final payload =
        await _api.get('/cart', token: token) as Map<String, dynamic>;
    return CartModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<CartModel> addCartItem(
      {required String token,
      required String productId,
      required int quantity}) async {
    final payload = await _api.post(
      '/cart/items',
      token: token,
      body: {'productId': productId, 'quantity': quantity},
    ) as Map<String, dynamic>;
    return CartModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<CartModel> updateCartItem(
      {required String token,
      required String itemId,
      required int quantity}) async {
    final payload = await _api.patch(
      '/cart/items/$itemId',
      token: token,
      body: {'quantity': quantity},
    ) as Map<String, dynamic>;
    return CartModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<CartModel> removeCartItem(
      {required String token, required String itemId}) async {
    final payload = await _api.delete('/cart/items/$itemId', token: token)
        as Map<String, dynamic>;
    return CartModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<CartModel> clearCart({required String token}) async {
    final payload =
        await _api.delete('/cart', token: token) as Map<String, dynamic>;
    return CartModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<CartModel> applyCoupon({
    required String token,
    required String code,
    required double subtotal,
  }) async {
    final payload = await _api.post(
      '/cart/coupon',
      token: token,
      body: {'code': code, 'subtotal': subtotal},
    ) as Map<String, dynamic>;
    return CartModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<CartModel> removeCoupon({required String token}) async {
    final payload =
        await _api.delete('/cart/coupon', token: token) as Map<String, dynamic>;
    return CartModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<UserModel> getProfile(String token) async {
    final payload =
        await _api.get('/users/me', token: token) as Map<String, dynamic>;
    return UserModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final payload = await _api.patch(
      '/users/me',
      token: token,
      body: {'firstName': firstName, 'lastName': lastName, 'phone': phone},
    ) as Map<String, dynamic>;
    return UserModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<String> deleteAccount({required String token}) async {
    final payload =
        await _api.delete('/users/me', token: token) as Map<String, dynamic>;
    return payload['message']?.toString() ?? 'Your account has been deleted.';
  }

  Future<List<AddressModel>> addAddress({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _api.post(
      '/users/addresses',
      token: token,
      body: payload,
    ) as Map<String, dynamic>;
    return (response['data'] as List<dynamic>? ?? const [])
        .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<AddressModel>> removeAddress({
    required String token,
    required String addressId,
  }) async {
    final response = await _api.delete(
      '/users/addresses/$addressId',
      token: token,
    ) as Map<String, dynamic>;
    return (response['data'] as List<dynamic>? ?? const [])
        .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> getWishlist(String token) async {
    final payload =
        await _api.get('/users/wishlist', token: token) as Map<String, dynamic>;
    return (payload['data'] as List<dynamic>? ?? const [])
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> addWishlistItem(
      {required String token, required String productId}) async {
    final payload = await _api.post('/users/wishlist/$productId', token: token)
        as Map<String, dynamic>;
    return (payload['data'] as List<dynamic>? ?? const [])
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> removeWishlistItem(
      {required String token, required String productId}) async {
    final payload = await _api.delete('/users/wishlist/$productId',
        token: token) as Map<String, dynamic>;
    return (payload['data'] as List<dynamic>? ?? const [])
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<OrderModel>> getOrders(String token) async {
    final payload =
        await _api.get('/orders/mine', token: token) as Map<String, dynamic>;
    return (payload['data'] as List<dynamic>? ?? const [])
        .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> getOrder(
      {required String token, required String orderId}) async {
    final payload = await _api.get('/orders/$orderId', token: token)
        as Map<String, dynamic>;
    return OrderModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<OrderModel> cancelOrder(
      {required String token, required String orderId}) async {
    final payload = await _api.patch('/orders/$orderId/cancel',
        token: token, body: const {}) as Map<String, dynamic>;
    return OrderModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<OrderTrackingResult> trackOrderShipment({
    required String token,
    required String orderId,
  }) async {
    final payload = await _api.get(
      '/shipping/aramex/orders/$orderId/tracking',
      token: token,
    ) as Map<String, dynamic>;
    return OrderTrackingResult.fromJson(
        payload['data'] as Map<String, dynamic>);
  }

  Future<OrderTrackingResult> trackOrderReturnShipment({
    required String token,
    required String orderId,
  }) async {
    final payload = await _api.get(
      '/shipping/aramex/orders/$orderId/return-tracking',
      token: token,
    ) as Map<String, dynamic>;
    return OrderTrackingResult.fromJson(
        payload['data'] as Map<String, dynamic>);
  }

  Future<OrderModel> requestOrderReturn({
    required String token,
    required String orderId,
    required String returnReason,
    String? returnDetails,
  }) async {
    final payload = await _api.post(
      '/orders/$orderId/return-request',
      token: token,
      body: {
        'returnReason': returnReason,
        if (returnDetails != null && returnDetails.trim().isNotEmpty)
          'returnDetails': returnDetails,
      },
    ) as Map<String, dynamic>;
    return OrderModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<StripePaymentIntentModel> createStripePaymentIntent({
    required String token,
    required String addressId,
  }) async {
    final payload = await _api.post(
      '/orders/stripe/payment-intent',
      token: token,
      body: {'addressId': addressId},
    ) as Map<String, dynamic>;
    return StripePaymentIntentModel.fromJson(
        payload['data'] as Map<String, dynamic>);
  }

  Future<ShippingQuoteModel> getShippingQuote({
    required String token,
    required String addressId,
  }) async {
    final payload = await _api.post(
      '/shipping/aramex/rate',
      token: token,
      body: {'addressId': addressId},
    ) as Map<String, dynamic>;
    return ShippingQuoteModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<OrderModel> createOrder({
    required String token,
    required String addressId,
    required String paymentMethod,
    String? paymentIntentId,
    String? notes,
  }) async {
    final payload = await _api.post(
      '/orders',
      token: token,
      body: {
        'addressId': addressId,
        'paymentMethod': paymentMethod,
        if (paymentIntentId != null && paymentIntentId.isNotEmpty)
          'paymentIntentId': paymentIntentId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    ) as Map<String, dynamic>;
    return OrderModel.fromJson(payload['data'] as Map<String, dynamic>);
  }
}
