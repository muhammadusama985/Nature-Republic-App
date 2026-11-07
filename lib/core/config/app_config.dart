class AppConfig {
  const AppConfig._();

  static const String appName = 'Nature Republic';
  static const String apiBaseUrl = 'https://kiss-paragraph-freely-dvds.trycloudflare.com/api';
  static const String stripePublishableKey =
      'pk_live_51SzFvmA9x1DejIaXDuwtQcrrVygUrzUv70njCuUbwvCFD7VCfjCvahdYuE3Y8IBh18i4Z2Ho4YQ74vZZWYC8NPh900SZ1AQ0lb';

  static String get mediaBaseUrl => apiBaseUrl.replaceFirst(RegExp(r'/api$'), '');
}
