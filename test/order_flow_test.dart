import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_customer_app/core/theme/app_theme.dart';
import 'package:flutter_customer_app/state/customer_store.dart';
import 'package:flutter_customer_app/ui/screens/order_detail_screen.dart';
import 'package:flutter_customer_app/ui/screens/orders_screen.dart';

final _png1x1 = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

Map<String, dynamic> _user() => {
      '_id': 'u1',
      'firstName': 'Noor',
      'lastName': 'Amin',
      'email': 'noor@example.com',
      'phone': '0501234567',
      'addresses': <Object>[],
    };

Map<String, dynamic> _product(String id, String name, double price, String slug) => {
      '_id': id,
      'slug': slug,
      'name': name,
      'description': '',
      'shortDescription': '',
      'categoryId': <String, dynamic>{'_id': 'c1', 'name': 'Skincare'},
      'categoryName': 'Skincare',
      'price': price,
      'stock': 25,
      'averageRating': 4.8,
      'reviewCount': 12,
      'images': <Object>['https://img.example/$slug.jpg'],
      'barcode': 'BC-$id',
    };

Map<String, dynamic> _orderDelivered() => {
      '_id': 'ord_1',
      'orderNumber': 'NR-1001',
      'orderStatus': 'delivered',
      'shippingStatus': 'delivered',
      'paymentMethod': 'stripe',
      'paymentStatus': 'paid',
      'pricing': <String, dynamic>{
        'subtotal': 180.5,
        'shippingAmount': 20,
        'discountAmount': 0,
        'total': 200.5,
      },
      'createdAt': '/Date(1730000000000+0400)/',
      'items': <Object>[
        {
          '_id': 'i1',
          'productId': _product('p1', 'Vitamin C Serum', 99.5, 'vitamin-c'),
          'quantity': 1,
          'lineTotal': 99.5,
        },
        {
          '_id': 'i2',
          'productId': _product('p2', 'Hydrating Moisturizer', 81, 'moisturizer'),
          'quantity': 1,
          'lineTotal': 81,
        },
      ],
      'trackingNumber': 'AE123456789',
      'returnStatus': '',
      'returnReason': '',
      'returnDetails': '',
      'returnTrackingNumber': '',
      'returnResolutionNote': '',
      'notes': 'Gift wrap please',
      'shippingAddress': <String, dynamic>{
        '_id': 'a1',
        'label': '',
        'fullName': 'Noor Amin',
        'phone': '0501234567',
        'country': 'AE',
        'city': 'Dubai',
        'area': '',
        'addressLine1': 'Marina Walk',
        'addressLine2': '',
        'postalCode': '',
        'isDefault': true,
      },
    };

Map<String, dynamic> _orderActiveReturn() => {
      '_id': 'ord_2',
      'orderNumber': 'NR-1002',
      'orderStatus': 'delivered',
      'shippingStatus': 'delivered',
      'paymentMethod': 'stripe',
      'paymentStatus': 'paid',
      'pricing': <String, dynamic>{'subtotal': 50, 'shippingAmount': 15, 'discountAmount': 0, 'total': 65},
      'createdAt': '2024-10-05T12:00:00',
      'items': <Object>[
        {
          '_id': 'i3',
          'productId': _product('p3', 'Lip Balm', 50, 'lip-balm'),
          'quantity': 1,
          'lineTotal': 50,
        },
      ],
      'trackingNumber': 'AE987654321',
      'returnStatus': 'approved',
      'returnReason': 'Wrong item',
      'returnDetails': 'Sent the wrong shade',
      'returnTrackingNumber': 'RET000123',
      'returnResolutionNote': '',
      'notes': '',
      'shippingAddress': <String, dynamic>{
        '_id': 'a2',
        'label': '',
        'fullName': 'Noor Amin',
        'phone': '0501234567',
        'country': 'AE',
        'city': 'Abu Dhabi',
        'area': '',
        'addressLine1': 'Corniche Road',
        'addressLine2': '',
        'postalCode': '',
        'isDefault': false,
      },
    };

Map<String, dynamic> _orderPending() => {
      '_id': 'ord_99',
      'orderNumber': 'NR-1099',
      'orderStatus': 'pending',
      'shippingStatus': '',
      'paymentMethod': 'stripe',
      'paymentStatus': 'unpaid',
      'pricing': <String, dynamic>{'subtotal': 160, 'shippingAmount': 15, 'discountAmount': 0, 'total': 175},
      'createdAt': '/Date(1730001000000+0400)/',
      'items': <Object>[
        {
          '_id': 'i4',
          'productId': _product('p4', 'Sunscreen SPF50', 90, 'sunscreen'),
          'quantity': 1,
          'lineTotal': 90,
        },
        {
          '_id': 'i5',
          'productId': _product('p5', 'Cleansing Gel', 70, 'cleanser'),
          'quantity': 1,
          'lineTotal': 70,
        },
      ],
      'trackingNumber': '',
      'returnStatus': '',
      'returnReason': '',
      'returnDetails': '',
      'returnTrackingNumber': '',
      'returnResolutionNote': '',
      'notes': '',
      'shippingAddress': null,
    };

Map<String, dynamic> _tracking() => {
      'ShipmentNumber': 'AE123456789',
      'TrackingResults': <Object>[
        {
          'ShipmentNumber': 'AE123456789',
          'HasErrors': false,
          'Notifications': <Object>[],
          'Events': <Object>[
            {
              'UpdateDescription': 'Delivered',
              'UpdateDateTime': '/Date(1730009000000+0400)/',
              'DisplayDescription': 'Delivered',
              'Location': 'Dubai',
            },
            {
              'UpdateDescription': 'In Transit',
              'UpdateDateTime': '2024-10-01T18:30:00',
              'DisplayDescription': 'In Transit',
              'Location': 'Sharjah',
            },
          ],
        }
      ],
    };

class _StubServer {
  List<int> respond(String method, Uri url) {
    final path = url.path.replaceFirst(RegExp('^/api'), '');
    Object body;
    if (path == '/auth/login') {
      body = <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'accessToken': 'tok',
          'refreshToken': 'rtok',
          'user': _user(),
        },
      };
    } else if (path == '/auth/me') {
      body = <String, dynamic>{'success': true, 'data': _user()};
    } else if (path == '/cart') {
      body = <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'items': <Object>[],
          'subtotal': 0,
          'discountAmount': 0,
          'total': 0,
        },
      };
    } else if (path == '/users/wishlist') {
      body = <String, dynamic>{'success': true, 'data': <Object>[]};
    } else if (path == '/orders/mine') {
      body = <String, dynamic>{
        'success': true,
        'data': <Object>[_orderDelivered(), _orderActiveReturn()],
      };
    } else if (path == '/orders/ord_99') {
      body = <String, dynamic>{'success': true, 'data': _orderPending()};
    } else if (path.startsWith('/shipping/aramex/orders/')) {
      body = <String, dynamic>{
        'success': true,
        'data': <String, dynamic>{'order': _orderDelivered(), 'tracking': _tracking()},
      };
    } else if (path.startsWith('/orders/')) {
      body = <String, dynamic>{'success': true, 'data': _orderDelivered()};
    } else {
      return _png1x1;
    }
    return utf8.encode(jsonEncode(body));
  }
}

class _StubHttpOverrides extends HttpOverrides {
  final _StubServer server = _StubServer();

  @override
  HttpClient createHttpClient(SecurityContext? context) => _StubHttpClient(server);
}

class _StubHttpClient implements HttpClient {
  _StubHttpClient(this.server);

  final _StubServer server;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _StubHttpClientRequest(server.respond(method, url), method, url);

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl('GET', url);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _StubHttpClientRequest implements HttpClientRequest {
  _StubHttpClientRequest(this._body, this.method, this.uri);

  final List<int> _body;
  @override
  final String method;
  @override
  final Uri uri;

  @override
  bool followRedirects = false;

  @override
  bool persistentConnection = false;

  @override
  int maxRedirects = 0;

  @override
  int contentLength = 0;

  @override
  final HttpHeaders headers = _StubHeaders();

  @override
  void add(List<int> data) {}

  @override
  Future<dynamic> addStream(Stream<List<int>> stream) => stream.drain<void>();

  @override
  Future<HttpClientResponse> close() async {
    return _StubHttpClientResponse(statusCode: 200, body: _body);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _StubHeaders implements HttpHeaders {
  final Map<String, List<String>> _values = <String, List<String>>{};

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _values.putIfAbsent(name.toLowerCase(), () => <String>[]).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _values[name.toLowerCase()] = <String>[value.toString()];
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _values.forEach(action);
  }

  @override
  String? value(String name, [String? defaultValue]) => defaultValue;

  String? userAgent = '';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _StubHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  _StubHttpClientResponse({required this.statusCode, required List<int> body}) : _body = Stream<List<int>>.fromIterable(<List<int>>[body]) {
    headers.set('content-type', 'application/json');
    contentLength = body.length;
  }

  final Stream<List<int>> _body;

  @override
  final HttpHeaders headers = _StubHeaders();

  @override
  int statusCode;

  @override
  int contentLength = 0;

  @override
  String reasonPhrase = 'OK';

  bool compressed = false;

  @override
  HttpClientResponseCompressionState compressionState = HttpClientResponseCompressionState.notCompressed;

  @override
  bool isRedirect = false;

  @override
  bool persistentConnection = true;

  int redirectCount = 0;

  @override
  List<RedirectInfo> redirects = <RedirectInfo>[];

  @override
  List<Cookie> cookies = <Cookie>[];

  Uri? get requestUri => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _body.listen((event) {
      onData?.call(event);
    }, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _app(CustomerStore store, {Widget? home}) {
  return ChangeNotifierProvider<CustomerStore>.value(
    value: store,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: home ?? const OrdersScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == OrderDetailScreen.routeName) {
          return MaterialPageRoute<dynamic>(
            builder: (_) => OrderDetailScreen(orderId: settings.arguments as String),
          );
        }
        return null;
      },
    ),
  );
}

Future<CustomerStore> _authedStore() async {
  final store = CustomerStore();
  await store.login(email: 'noor@example.com', password: 'secret');
  return store;
}

void main() {
  setUp(() {
    HttpOverrides.global = _StubHttpOverrides();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('orders list -> delivered order detail renders and tracks', (tester) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final store = await _authedStore();
    await tester.pumpWidget(_app(store));
    await tester.pumpAndSettle();

    expect(find.text('#NR-1001'), findsOneWidget);
    expect(find.text('#NR-1002'), findsOneWidget);

    await tester.tap(find.text('#NR-1001'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Vitamin C Serum'), findsOneWidget);
    expect(find.text('Need to Return?'), findsOneWidget);
    expect(find.text('Aramex Tracking'), findsOneWidget);
    expect(find.text('Gift wrap please'), findsOneWidget);

    await tester.tap(find.text('Track'));
    await tester.pumpAndSettle();

    expect(find.textContaining('AE123456789'), findsWidgets);
    expect(find.text('Delivered'), findsOneWidget);
    expect(find.text('In Transit'), findsOneWidget);
  });

  testWidgets('order detail fetches and renders an unknown order via loadOrder (regression)', (tester) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final store = await _authedStore();
    await tester.pumpWidget(_app(store, home: const OrderDetailScreen(orderId: 'ord_99')));
    await tester.pumpAndSettle();

    expect(find.text('#NR-1099'), findsOneWidget);
    expect(find.text('Cancel Order'), findsOneWidget);
  });

  testWidgets('order detail renders the active-return card', (tester) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final store = await _authedStore();
    await tester.pumpWidget(_app(store, home: const OrderDetailScreen(orderId: 'ord_2')));
    await tester.pumpAndSettle();

    expect(find.text('Return Status'), findsOneWidget);
    expect(find.textContaining('RET000123'), findsOneWidget);
    expect(find.text('Wrong item'), findsOneWidget);
    expect(find.text('Track Return'), findsOneWidget);
  });
}