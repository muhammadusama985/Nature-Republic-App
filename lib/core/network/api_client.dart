import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiClient {
  ApiClient({required this.onUnauthorized});

  final Future<String?> Function() onUnauthorized;

  Future<dynamic> get(
    String path, {
    String? token,
    bool allowRefresh = true,
  }) {
    return _request(
      path,
      method: 'GET',
      token: token,
      allowRefresh: allowRefresh,
    );
  }

  Future<dynamic> post(
    String path, {
    String? token,
    Object? body,
    bool allowRefresh = true,
  }) {
    return _request(
      path,
      method: 'POST',
      token: token,
      body: body,
      allowRefresh: allowRefresh,
    );
  }

  Future<dynamic> patch(
    String path, {
    String? token,
    Object? body,
    bool allowRefresh = true,
  }) {
    return _request(
      path,
      method: 'PATCH',
      token: token,
      body: body,
      allowRefresh: allowRefresh,
    );
  }

  Future<dynamic> delete(
    String path, {
    String? token,
    Object? body,
    bool allowRefresh = true,
  }) {
    return _request(
      path,
      method: 'DELETE',
      token: token,
      body: body,
      allowRefresh: allowRefresh,
    );
  }

  Future<dynamic> _request(
    String path, {
    required String method,
    String? token,
    Object? body,
    bool allowRefresh = true,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    http.Response response = await _send(method, uri, headers, body);

    if (response.statusCode == 401 && allowRefresh && !path.startsWith('/auth/')) {
      final refreshedToken = await onUnauthorized();
      if (refreshedToken != null) {
        final nextHeaders = <String, String>{
          ...headers,
          'Authorization': 'Bearer $refreshedToken',
        };
        response = await _send(method, uri, nextHeaders, body);
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Request failed for $path';
      try {
        final payload = jsonDecode(response.body) as Map<String, dynamic>;
        message = payload['message']?.toString() ?? message;
      } catch (_) {}
      throw Exception(message);
    }

    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  Future<http.Response> _send(
    String method,
    Uri uri,
    Map<String, String> headers,
    Object? body,
  ) {
    switch (method) {
      case 'POST':
        return http.post(uri, headers: headers, body: body == null ? null : jsonEncode(body));
      case 'PATCH':
        return http.patch(uri, headers: headers, body: body == null ? null : jsonEncode(body));
      case 'DELETE':
        return http.delete(uri, headers: headers, body: body == null ? null : jsonEncode(body));
      default:
        return http.get(uri, headers: headers);
    }
  }
}
