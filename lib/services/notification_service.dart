import 'dart:async';
import 'package:flutter/foundation.dart';

/// Notification event type
enum NotificationType {
  orderPlaced,
  orderAccepted,
  kitchenPreparing,
  courierDispatched,
  courierArriving,
  orderDelivered,
  promotional,
}

/// Notification payload model
class ClickBiteNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final String? orderId;
  final Map<String, dynamic>? data;

  const ClickBiteNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.orderId,
    this.data,
  });
}

/// Central Push Notification & In-App Alert Service for ClickBite
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<ClickBiteNotification> _notifications = [];
  final StreamController<ClickBiteNotification> _notificationStreamController =
      StreamController<ClickBiteNotification>.broadcast();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  List<ClickBiteNotification> get notifications => List.unmodifiable(_notifications);
  Stream<ClickBiteNotification> get onNotificationReceived =>
      _notificationStreamController.stream;

  /// Register or refresh Firebase Cloud Messaging token for authenticated user
  Future<void> registerFcmToken(String userId) async {
    // Generate deterministic device registration token
    _fcmToken = 'fcm_token_${userId.hashCode.abs()}_${DateTime.now().millisecondsSinceEpoch}';
    if (kDebugMode) {
      debugPrint('[NotificationService] Registered FCM token for user $userId: $_fcmToken');
    }
    notifyListeners();
  }

  /// Dispatch an in-app and simulated push notification for order lifecycle changes
  void postOrderNotification({
    required String orderId,
    required NotificationType type,
    String? customMessage,
  }) {
    String title;
    String body;

    switch (type) {
      case NotificationType.orderPlaced:
        title = 'Order Placed Successfully!';
        body = 'Your order #$orderId has been received and routed to the kitchen.';
        break;
      case NotificationType.orderAccepted:
        title = 'Kitchen Accepted Your Order';
        body = 'Nana\'s Kitchen has accepted your order and began meal preparations.';
        break;
      case NotificationType.kitchenPreparing:
        title = 'Food is Sizzling Hot! 🍲';
        body = 'Your meal is actively cooking on the firewood stove in Konongo.';
        break;
      case NotificationType.courierDispatched:
        title = 'Courier Kofi Boateng on Route! 🛵';
        body = 'Your food is packaged and Kofi is navigating the Konongo bypass road.';
        break;
      case NotificationType.courierArriving:
        title = 'Courier Arriving in 2 Minutes! 📍';
        body = 'Look out for the ClickBite branded bike outside your destination.';
        break;
      case NotificationType.orderDelivered:
        title = 'Order Delivered! Enjoy Your Meal 🎉';
        body = 'Your delivery is complete. Don\'t forget to rate your dish!';
        break;
      case NotificationType.promotional:
        title = 'Special Deal in Konongo!';
        body = customMessage ?? 'Enjoy 15% off your next firewood Jollof bowl!';
        break;
    }

    if (customMessage != null && type != NotificationType.promotional) {
      body = customMessage;
    }

    final notification = ClickBiteNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      orderId: orderId,
    );

    _notifications.insert(0, notification);
    _notificationStreamController.add(notification);
    notifyListeners();

    if (kDebugMode) {
      debugPrint('[NotificationService] Notification dispatched: $title - $body');
    }
  }

  /// Clear all notification history
  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
