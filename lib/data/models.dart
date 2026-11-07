import 'package:flutter/foundation.dart';

import '../core/config/app_config.dart';

@immutable
class AddressModel {
  const AddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.country,
    required this.city,
    required this.area,
    required this.addressLine1,
    required this.addressLine2,
    required this.postalCode,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String country;
  final String city;
  final String area;
  final String addressLine1;
  final String addressLine2;
  final String postalCode;
  final bool isDefault;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      addressLine1: json['addressLine1']?.toString() ?? '',
      addressLine2: json['addressLine2']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
    );
  }
}

@immutable
class BannerModel {
  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String image;

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? json['label']?.toString() ?? '',
      description: json['description']?.toString() ?? json['shortDescription']?.toString() ?? '',
      image: _media(json['image']),
    );
  }
}

@immutable
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  final String id;
  final String name;
  final String description;
  final String image;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: _media(json['image']),
    );
  }
}

@immutable
class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.author,
    required this.title,
    required this.comment,
    required this.rating,
  });

  final String id;
  final String author;
  final String title;
  final String comment;
  final int rating;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['userId'] as Map<String, dynamic>?;
    final firstName = user?['firstName']?.toString() ?? '';
    final lastName = user?['lastName']?.toString() ?? '';
    return ReviewModel(
      id: json['_id']?.toString() ?? '',
      author: '$firstName $lastName'.trim().isEmpty ? 'Customer' : '$firstName $lastName'.trim(),
      title: json['title']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      rating: (json['rating'] as num?)?.round() ?? 0,
    );
  }
}

@immutable
class ProductModel {
  const ProductModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.stock,
    required this.averageRating,
    required this.reviewCount,
    required this.images,
    required this.barcode,
  });

  final String id;
  final String slug;
  final String name;
  final String description;
  final String shortDescription;
  final String categoryId;
  final String categoryName;
  final double price;
  final int stock;
  final double averageRating;
  final int reviewCount;
  final List<String> images;
  final String barcode;

  bool get isOutOfStock => stock <= 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['categoryId'];
    return ProductModel(
      id: json['_id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      shortDescription: json['shortDescription']?.toString() ?? '',
      categoryId: category is Map<String, dynamic> ? category['_id']?.toString() ?? '' : '',
      categoryName: category is Map<String, dynamic> ? category['name']?.toString() ?? '' : '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.round() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.round() ?? 0,
      images: (json['images'] as List<dynamic>? ?? const [])
          .map((item) => _media(item?.toString()))
          .where((item) => item.isNotEmpty)
          .toList(),
      barcode: json['barcode']?.toString() ?? '',
    );
  }
}

@immutable
class ProductDetailModel {
  const ProductDetailModel({
    required this.product,
    required this.reviews,
  });

  final ProductModel product;
  final List<ReviewModel> reviews;

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>? ?? const {}),
      reviews: (json['reviews'] as List<dynamic>? ?? const [])
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

@immutable
class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.lineTotal,
  });

  final String id;
  final ProductModel product;
  final int quantity;
  final double lineTotal;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productValue = json['productId'];
    final fallbackPrice = (json['unitPrice'] as num?)?.toDouble() ?? 0;
    final fallbackName = json['name']?.toString() ?? '';
    final fallbackImage = _media(json['image']?.toString());
    final product = productValue is Map<String, dynamic>
        ? ProductModel.fromJson(productValue)
        : ProductModel(
            id: productValue?.toString() ?? '',
            slug: '',
            name: fallbackName,
            description: '',
            shortDescription: '',
            categoryId: '',
            categoryName: '',
            price: fallbackPrice,
            stock: 0,
            averageRating: 0,
            reviewCount: 0,
            images: fallbackImage.isEmpty ? const [] : [fallbackImage],
            barcode: '',
          );
    final quantity = (json['quantity'] as num?)?.round() ?? 1;
    final explicitLineTotal = (json['lineTotal'] as num?)?.toDouble();
    return CartItemModel(
      id: json['_id']?.toString() ?? '',
      product: product,
      quantity: quantity,
      lineTotal: explicitLineTotal ?? (product.price * quantity),
    );
  }
}

@immutable
class CartModel {
  const CartModel({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  final List<CartItemModel> items;
  final double subtotal;
  final double discount;
  final double total;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  factory CartModel.empty() => const CartModel(items: [], subtotal: 0, discount: 0, total: 0);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}

@immutable
class UserModel {
  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.addresses,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final List<AddressModel> addresses;

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      addresses: (json['addresses'] as List<dynamic>? ?? const [])
          .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

@immutable
class ShippingQuoteModel {
  const ShippingQuoteModel({
    required this.provider,
    required this.shippingAmount,
    required this.currency,
    required this.configured,
  });

  final String provider;
  final double shippingAmount;
  final String currency;
  final bool configured;

  factory ShippingQuoteModel.fromJson(Map<String, dynamic> json) {
    return ShippingQuoteModel(
      provider: json['provider']?.toString() ?? 'aramex',
      shippingAmount: (json['shippingAmount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'AED',
      configured: json['configured'] == true,
    );
  }
}

@immutable
class StripePaymentIntentModel {
  const StripePaymentIntentModel({
    required this.paymentIntentId,
    required this.clientSecret,
    required this.amount,
    required this.currency,
  });

  final String paymentIntentId;
  final String clientSecret;
  final double amount;
  final String currency;

  factory StripePaymentIntentModel.fromJson(Map<String, dynamic> json) {
    return StripePaymentIntentModel(
      paymentIntentId: json['paymentIntentId']?.toString() ?? '',
      clientSecret: json['clientSecret']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'AED',
    );
  }
}

@immutable
class BlogPostModel {
  const BlogPostModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.coverImage,
  });

  final String id;
  final String slug;
  final String title;
  final String excerpt;
  final String content;
  final String coverImage;

  factory BlogPostModel.fromJson(Map<String, dynamic> json) {
    return BlogPostModel(
      id: json['_id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      excerpt: json['excerpt']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      coverImage: _media(json['coverImage']),
    );
  }
}

@immutable
class ContentPageModel {
  const ContentPageModel({
    required this.slug,
    required this.title,
    required this.content,
  });

  final String slug;
  final String title;
  final String content;

  factory ContentPageModel.fromJson(Map<String, dynamic> json) {
    return ContentPageModel(
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }
}

@immutable
class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.orderStatus,
    required this.shippingStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.shippingAmount,
    required this.discountAmount,
    required this.total,
    required this.createdAt,
    required this.items,
    required this.trackingNumber,
    required this.returnStatus,
    required this.returnReason,
    required this.returnDetails,
    required this.returnTrackingNumber,
    required this.returnResolutionNote,
    required this.notes,
    required this.shippingAddress,
  });

  final String id;
  final String orderNumber;
  final String status;
  final String orderStatus;
  final String shippingStatus;
  final String paymentMethod;
  final String paymentStatus;
  final double subtotal;
  final double shippingAmount;
  final double discountAmount;
  final double total;
  final String createdAt;
  final List<CartItemModel> items;
  final String trackingNumber;
  final String returnStatus;
  final String returnReason;
  final String returnDetails;
  final String returnTrackingNumber;
  final String returnResolutionNote;
  final String notes;
  final AddressModel? shippingAddress;

  bool get isDelivered => orderStatus == 'delivered' || shippingStatus == 'delivered';

  bool get hasActiveReturn => returnStatus.isNotEmpty && returnStatus != 'none';

  bool get canRequestReturn =>
      isDelivered &&
      orderStatus != 'cancelled' &&
      (returnStatus.isEmpty || returnStatus == 'none' || returnStatus == 'rejected');

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] as Map<String, dynamic>?;
    final addressValue = json['shippingAddress'];
    return OrderModel(
      id: json['_id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? json['_id']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? json['status']?.toString() ?? 'pending',
      status: json['orderStatus']?.toString() ?? json['status']?.toString() ?? 'pending',
      shippingStatus: json['shippingStatus']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      subtotal: (pricing?['subtotal'] as num?)?.toDouble() ?? (json['subtotal'] as num?)?.toDouble() ?? 0,
      shippingAmount: (pricing?['shippingAmount'] as num?)?.toDouble() ?? (json['shippingAmount'] as num?)?.toDouble() ?? 0,
      discountAmount: (pricing?['discountAmount'] as num?)?.toDouble() ?? (json['discountAmount'] as num?)?.toDouble() ?? 0,
      total: (pricing?['total'] as num?)?.toDouble() ??
          (json['totalAmount'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          0,
      createdAt: json['createdAt']?.toString() ?? '',
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      trackingNumber: json['trackingNumber']?.toString() ?? '',
      returnStatus: json['returnStatus']?.toString() ?? '',
      returnReason: json['returnReason']?.toString() ?? '',
      returnDetails: json['returnDetails']?.toString() ?? '',
      returnTrackingNumber: json['returnTrackingNumber']?.toString() ?? '',
      returnResolutionNote: json['returnResolutionNote']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      shippingAddress: addressValue is Map<String, dynamic>
          ? AddressModel.fromJson(addressValue)
          : null,
    );
  }
}

@immutable
class TrackingEventModel {
  const TrackingEventModel({
    required this.updateDescription,
    required this.updateDateTime,
    required this.displayDescription,
    required this.location,
    required this.eventDate,
    required this.eventTime,
  });

  final String updateDescription;
  final String updateDateTime;
  final String displayDescription;
  final String location;
  final String eventDate;
  final String eventTime;

  String get statusText =>
      displayDescription.isNotEmpty ? displayDescription : updateDescription;

  factory TrackingEventModel.fromJson(Map<String, dynamic> json) {
    return TrackingEventModel(
      updateDescription: json['UpdateDescription']?.toString() ?? json['StatusDescription']?.toString() ?? '',
      updateDateTime: json['UpdateDateTime']?.toString() ?? '',
      displayDescription: json['DisplayDescription']?.toString() ?? '',
      location: json['Location']?.toString() ?? '',
      eventDate: json['EventDate']?.toString() ?? '',
      eventTime: json['EventTime']?.toString() ?? '',
    );
  }
}

@immutable
class TrackingResultModel {
  const TrackingResultModel({
    required this.shipmentNumber,
    required this.hasErrors,
    required this.errorMessage,
    required this.events,
  });

  final String shipmentNumber;
  final bool hasErrors;
  final String errorMessage;
  final List<TrackingEventModel> events;

  factory TrackingResultModel.fromJson(Map<String, dynamic> json) {
    final results = json['TrackingResults'] as List<dynamic>? ?? const [];
    final result = results.isNotEmpty ? results.first as Map<String, dynamic> : null;
    final notifications = result?['Notifications'] as List<dynamic>? ?? const [];
    final firstNotification = notifications.isEmpty ? null : notifications.first;
    final firstMessage = firstNotification is Map<String, dynamic>
        ? firstNotification['Message']?.toString() ?? ''
        : '';
    return TrackingResultModel(
      shipmentNumber: result?['ShipmentNumber']?.toString() ?? '',
      hasErrors: result?['HasErrors'] == true,
      errorMessage: firstMessage,
      events: _parseEvents(result),
    );
  }

  static List<TrackingEventModel> _parseEvents(Map<String, dynamic>? result) {
    final events = result?['Events'];
    if (events is List && events.isNotEmpty) {
      return events
          .map((item) => TrackingEventModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    final legacy = result?['Value'];
    if (legacy is List && legacy.isNotEmpty) {
      return legacy
          .map((item) => TrackingEventModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    final updateDescription = result?['UpdateDescription']?.toString() ?? '';
    if (updateDescription.isEmpty) return const [];
    return [
      TrackingEventModel(
        updateDescription: updateDescription,
        updateDateTime: result?['UpdateDateTime']?.toString() ?? '',
        displayDescription: result?['DisplayDescription']?.toString() ?? '',
        location: result?['Destination']?.toString() ?? result?['Location']?.toString() ?? '',
        eventDate: '',
        eventTime: '',
      ),
    ];
  }
}

@immutable
class OrderTrackingResult {
  const OrderTrackingResult({required this.order, this.tracking});

  final OrderModel order;
  final TrackingResultModel? tracking;

  factory OrderTrackingResult.fromJson(Map<String, dynamic> json) {
    return OrderTrackingResult(
      order: OrderModel.fromJson(json['order'] as Map<String, dynamic>? ?? const {}),
      tracking: json['tracking'] == null
          ? null
          : TrackingResultModel.fromJson(json['tracking'] as Map<String, dynamic>),
    );
  }
}

@immutable
class HomePayload {
  const HomePayload({
    required this.banners,
    required this.categories,
    required this.featuredProducts,
    required this.bestSellingProducts,
  });

  final List<BannerModel> banners;
  final List<CategoryModel> categories;
  final List<ProductModel> featuredProducts;
  final List<ProductModel> bestSellingProducts;

  factory HomePayload.fromJson(Map<String, dynamic> json) {
    final banners = (json['banners'] as List<dynamic>? ?? const [])
        .map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return HomePayload(
      banners: banners.where((item) => item.image.isNotEmpty).toList(),
      categories: (json['categories'] as List<dynamic>? ?? const [])
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      featuredProducts: (json['featuredProducts'] as List<dynamic>? ?? const [])
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      bestSellingProducts: (json['bestSellingProducts'] as List<dynamic>? ?? const [])
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

@immutable
class ChatbotReplyModel {
  const ChatbotReplyModel({
    required this.reply,
    required this.suggestions,
    required this.products,
    required this.categories,
  });

  final String reply;
  final List<String> suggestions;
  final List<ProductModel> products;
  final List<CategoryModel> categories;

  factory ChatbotReplyModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    return ChatbotReplyModel(
      reply: data['reply']?.toString() ?? '',
      suggestions: (data['suggestions'] as List<dynamic>? ?? const [])
          .map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList(),
      products: (data['products'] as List<dynamic>? ?? const [])
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      categories: (data['categories'] as List<dynamic>? ?? const [])
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

String _media(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return '${AppConfig.mediaBaseUrl}${path.startsWith('/') ? path : '/$path'}';
}
