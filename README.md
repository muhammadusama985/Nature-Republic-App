# Flutter Customer App

This folder contains a separate Flutter customer application based on the current mobile storefront design and backend flows.

## Features scaffolded

- Customer auth: login, register, logout, persisted session
- Home screen with hero banner, categories, featured products, top sellers
- Products listing
- Product detail with quantity, add to cart, wishlist, reviews, related products
- Cart
- Wishlist
- Profile
- Orders
- Shared floral/mobile-inspired theme using the same exported assets

## Configure backend

Update the backend API value in:

- `lib/core/config/app_config.dart`

Example:

```dart
static const String apiBaseUrl = 'https://your-backend-domain/api';
```

## Run

```bash
flutter pub get
flutter run
```

## Notes

- This app is wired to the current Express backend routes already used by the web app.
- Stripe checkout and some content pages can be extended from this base once the Flutter SDK is available locally for live testing.
