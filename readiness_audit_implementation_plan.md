# ClickBite Production Readiness Implementation Plan

This roadmap outlines the complete path from local development to production deployment for **ClickBite - Food & Beverage Delivery** in Konongo, Ashanti Region.

---

## Phase Overview & Progress Matrix

| Phase | Focus Area | Status | Key Deliverables |
| :--- | :--- | :---: | :--- |
| **Phase 1** | **Android & Technical Release Readiness** | **In Progress** | Release permissions, keystore signing, R8 optimization, split-per-abi build, icon/splash integrity. |
| **Phase 2** | **Live Backend, Database & Auth** | Pending | Supabase production environment, SMS OTP authentication, live PostgreSQL RLS deployment. |
| **Phase 3** | **Real Ghana MoMo & Courier Engine** | Pending | Paystack/Hubtel payment gateway integration, live Supabase Realtime tracking for riders. |
| **Phase 4** | **Store Deployment, Web & Monitoring** | Pending | Google Play Store listing, Web production hosting, Sentry crash telemetry. |

---

## Phase 1: Android & Technical Release Readiness

> [!IMPORTANT]
> The primary objective of Phase 1 is ensuring that release builds compile deterministically, consume minimal download bandwidth, include necessary release permissions, and have a secure signing pipeline.

### Step 1.1: Release Permissions & App Metadata *(Completed)*
- [x] Added `android.permission.INTERNET` and `ACCESS_NETWORK_STATE` to [`AndroidManifest.xml`](file:///c:/Users/demiurge/Desktop/my%20food%20app/android/app/src/main/AndroidManifest.xml) for OpenStreetMap tiles and API requests in release mode.
- [x] Configured user-facing application label to `ClickBite`.
- [x] Generated standard DPI launcher icons and adaptive icons (`mipmap-anydpi-v26`).

### Step 1.2: Release Keystore & Gradle Signing Pipeline *(Completed)*
- [x] Configured [`app/build.gradle.kts`](file:///c:/Users/demiurge/Desktop/my%20food%20app/android/app/build.gradle.kts) to dynamically read upload credentials from `android/key.properties`.
- [x] Provided automatic fallback to debug keys when building without local release keys, preventing team build breakages.
- [x] Verified `key.properties` and `*.jks` are ignored in [`android/.gitignore`](file:///c:/Users/demiurge/Desktop/my%20food%20app/android/.gitignore).

### Step 1.3: Code Shrinking, Resource Stripping & ProGuard *(In Progress)*
- [x] Enabled `isMinifyEnabled = true` and `isShrinkResources = true`.
- [x] Added [`proguard-rules.pro`](file:///c:/Users/demiurge/Desktop/my%20food%20app/android/app/proguard-rules.pro) preserving Flutter engine, JNI bridges, and reflection entrypoints.
- [ ] Resolve Gradle build transforms workspace cache lock and validate release APK (`--split-per-abi`).

### Step 1.4: UI Ink & Viewport Warning Cleanups *(Completed)*
- [x] Cleaned up obsolete `viewport` meta tag in [`web/index.html`](file:///c:/Users/demiurge/Desktop/my%20food%20app/web/index.html).
- [x] Wrapped modal sheet `ListTile` elements in `Material(type: MaterialType.transparency)` across [`home_screen.dart`](file:///c:/Users/demiurge/Desktop/my%20food%20app/lib/screens/home_screen.dart), [`order_tracking_screen.dart`](file:///c:/Users/demiurge/Desktop/my%20food%20app/lib/screens/order_tracking_screen.dart), and [`profile_screen.dart`](file:///c:/Users/demiurge/Desktop/my%20food%20app/lib/screens/profile_screen.dart).

---

## Phase 2: Live Firebase Backend, Firestore & Phone Auth Deployment

> [!NOTE]
> ClickBite utilizes Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`) for seamless phone OTP verification in Ghana, automatic client-side offline persistence, and low-latency order updates.

### Step 2.1: Firebase Environment & SDK Setup *(Completed)*
- [x] Placed `google-services.json` in `android/app/` with package ID `com.lextech.clickbite`.
- [x] Configured `android/settings.gradle.kts` and `android/app/build.gradle.kts` with `com.google.gms.google-services`.
- [x] Added `firebase_core`, `firebase_auth`, and `cloud_firestore` to [`pubspec.yaml`](file:///c:/Users/demiurge/Desktop/my%20food%20app/pubspec.yaml).
- [x] Generated [`firebase_options.dart`](file:///c:/Users/demiurge/Desktop/my%20food%20app/lib/firebase_options.dart) for project `clickbitedelivery`.
- [x] Placed `GoogleService-Info.plist` for iOS in `ios/Runner/`.

### Step 2.2: Firebase Phone Number OTP Authentication *(Completed)*
- [x] Connect [`firebase_auth_service.dart`](file:///c:/Users/demiurge/Desktop/my%20food%20app/lib/services/firebase_auth_service.dart) and Auth UI to `FirebaseAuth.instance.verifyPhoneNumber`.
- [x] Support Ghanaian telecom numbers (`+233 24/54/55/20/50/27/26`) with carrier detector, auto-retrieval, and manual 6-digit OTP code input in [`auth_screen.dart`](file:///c:/Users/demiurge/Desktop/my%20food%20app/lib/screens/auth_screen.dart).
- [x] Added Email/Password tab and session integration with [`security_service.dart`](file:///c:/Users/demiurge/Desktop/my%20food%20app/lib/services/security_service.dart).

### Step 2.3: Cloud Firestore Data Collections & Security Rules *(Completed)*
- [x] Deployed collections for `categories`, `vendors`, `menu_items`, and `orders` using Admin SDK (`scripts/seed_firestore.js`) with 6 authentic Konongo restaurants, 15 dishes, and 7 categories.
- [x] Deployed Firestore Security Rules ([`firestore.rules`](file:///c:/Users/demiurge/Desktop/my%20food%20app/firestore.rules)):
  - Customers: Read approved vendors, read menu, create/view own orders.
  - Vendors: Update kitchen availability, manage own menu dishes, change order status (`PREPARING`, `READY`).
  - Couriers: Read assigned delivery route details.

### Step 2.4: Realtime Order Sync & Offline Persistence *(Completed)*
- [x] Implemented `FirebaseFirestoreService` with offline cache enabled for automatic local queueing during intermittent network in Konongo.
- [x] Connected [`restaurants_screen.dart`](file:///c:/Users/demiurge/Desktop/my%20food%20app/lib/screens/restaurants_screen.dart) to live `streamVendors()` with instant offline fallback.
- [x] Connected [`cart_screen.dart`](file:///c:/Users/demiurge/Desktop/my%20food%20app/lib/screens/cart_screen.dart) checkout to `submitOrder()`.
- [x] Connected [`order_tracking_screen.dart`](file:///c:/Users/demiurge/Desktop/my%20food%20app/lib/screens/order_tracking_screen.dart) to live active order stream.

---

## Phase 3: Real Ghana MoMo Payments & Live Courier Dispatch

> [!TIP]
> Food delivery conversion in Ghana relies heavily on seamless Mobile Money prompt popups (MTN MoMo, Telecel Cash).

### Step 3.1: Paystack Ghana Payment Gateway
- [ ] Integrate Paystack API for MoMo charge initiation.
- [ ] In [`cart_screen.dart`](file:///c:/Users/demiurge/Desktop/my%20food%20app/lib/screens/cart_screen.dart):
  - Customer selects MoMo network & enters number.
  - Paystack triggers an instant USSD authorization prompt on customer's device.
  - Webhook verifies payment and transitions order status to `preparing`.

### Step 3.2: Supabase Realtime Courier Telemetry
- [ ] Subscribe [`live_map_tracker.dart`](file:///c:/Users/demiurge/Desktop/my%20food%20app/lib/widgets/live_map_tracker.dart) to Supabase Realtime channel for active `order_id`.
- [ ] Replace simulated coordinate progress with real latitude/longitude broadcast by the dispatch rider app.

### Step 3.3: Push Notifications (Firebase Cloud Messaging)
- [ ] Register FCM tokens on login.
- [ ] Send status push notifications: Order Accepted → Food Ready → Courier Dispatched → Arrived.

---

## Phase 4: Store Deployment, Web Hosting & Crash Monitoring

### Step 4.1: Google Play Console Release
- [ ] Generate production Android App Bundle (`flutter build appbundle --release`).
- [ ] Upload bundle to Google Play Internal/Closed Testing track.
- [ ] Publish Store Listing with privacy policy URL ([`privacy_policy_screen.dart`](file:///c:/Users/demiurge/Desktop/my%20food%20app/lib/screens/legal/privacy_policy_screen.dart)).

### Step 4.2: Web Production Deployment
- [ ] Build production web bundle (`flutter build web --release`).
- [ ] Deploy to custom domain (`clickbite.com` or `clickbites.gh`) on Firebase Hosting / Cloudflare Pages.

### Step 4.3: Real-time Crash Telemetry
- [ ] Add Sentry or Firebase Crashlytics to report unhandled production exceptions with device metadata.
