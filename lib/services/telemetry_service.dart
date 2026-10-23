import 'package:flutter/foundation.dart';

/// Telemetry breadcrumb recording user actions prior to an error
class TelemetryBreadcrumb {
  final String message;
  final String category;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const TelemetryBreadcrumb({
    required this.message,
    this.category = 'ui',
    required this.timestamp,
    this.data,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'category': category,
        'timestamp': timestamp.toIso8601String(),
        'data': data,
      };
}

/// Crash report payload structure
class CrashReport {
  final String id;
  final String error;
  final String stackTrace;
  final String? reason;
  final bool isFatal;
  final DateTime timestamp;
  final List<TelemetryBreadcrumb> breadcrumbs;
  final Map<String, dynamic> deviceContext;

  const CrashReport({
    required this.id,
    required this.error,
    required this.stackTrace,
    this.reason,
    required this.isFatal,
    required this.timestamp,
    required this.breadcrumbs,
    required this.deviceContext,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'error': error,
        'stackTrace': stackTrace,
        'reason': reason,
        'isFatal': isFatal,
        'timestamp': timestamp.toIso8601String(),
        'breadcrumbs': breadcrumbs.map((b) => b.toJson()).toList(),
        'deviceContext': deviceContext,
      };
}

/// Production Crash Telemetry & Exception Monitoring Service for ClickBite
/// Compatible with Sentry, Firebase Crashlytics, and custom cloud logging
class TelemetryService {
  static final TelemetryService _instance = TelemetryService._internal();
  factory TelemetryService() => _instance;
  TelemetryService._internal();

  final List<TelemetryBreadcrumb> _breadcrumbs = [];
  final List<CrashReport> _crashReports = [];
  bool _isInitialized = false;

  List<CrashReport> get crashReports => List.unmodifiable(_crashReports);

  /// Initialize telemetry interception for Flutter framework and Dart VM
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Capture Flutter framework errors (Widget build exceptions, layout overflows)
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      recordError(
        details.exception,
        details.stack ?? StackTrace.current,
        reason: details.context?.toString() ?? 'Flutter framework error',
        fatal: false,
      );
      if (originalOnError != null) {
        originalOnError(details);
      }
    };

    // 2. Capture asynchronous unhandled Dart errors
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(
        error,
        stack,
        reason: 'Unhandled asynchronous error',
        fatal: true,
      );
      return true;
    };

    addBreadcrumb('TelemetryService initialized for ClickBite Konongo', category: 'app_lifecycle');
    if (kDebugMode) {
      debugPrint('[TelemetryService] Global crash & exception monitoring activated.');
    }
  }

  /// Add a diagnostic breadcrumb for telemetry tracing
  void addBreadcrumb(String message, {String category = 'action', Map<String, dynamic>? data}) {
    if (_breadcrumbs.length >= 50) {
      _breadcrumbs.removeAt(0);
    }
    _breadcrumbs.add(TelemetryBreadcrumb(
      message: message,
      category: category,
      timestamp: DateTime.now(),
      data: data,
    ));
  }

  /// Record an handled or unhandled exception
  void recordError(
    Object exception,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    final report = CrashReport(
      id: 'crash_${DateTime.now().millisecondsSinceEpoch}',
      error: exception.toString(),
      stackTrace: stackTrace.toString(),
      reason: reason,
      isFatal: fatal,
      timestamp: DateTime.now(),
      breadcrumbs: List.from(_breadcrumbs),
      deviceContext: {
        'platform': kIsWeb ? 'Web' : defaultTargetPlatform.name,
        'appVersion': '1.0.0+1',
        'buildMode': kReleaseMode ? 'release' : (kProfileMode ? 'profile' : 'debug'),
      },
    );

    _crashReports.add(report);

    if (kDebugMode) {
      debugPrint('[TelemetryService] Recorded error: ${report.error} (Fatal: $fatal)');
    }
  }

  /// Clear stored crash reports (e.g. after successful cloud sync)
  void clearReports() {
    _crashReports.clear();
  }
}
