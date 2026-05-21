import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// The target levels of logging diagnostics.
enum LogLevel {
  debug,
  info,
  warning,
  error,
  severe,
}

/// **Core Layer - Premium Console Logging Utility**
/// 
/// Provides unified diagnostic outputs styled with emojis and ANSI escape sequence colors.
/// Automatically filters diagnostic levels dynamically based on the active [AppConfig] environment flavor.
class AppLogger {
  /// The scope/class tag of the active logger module.
  final String tag;

  const AppLogger._(this.tag);

  /// Spawns a new logger instance configured for a specific domain/class name.
  factory AppLogger.of(String tag) => AppLogger._(tag);

  /// Evaluates the current active flavor, gracefully falling back to dev if uninitialized.
  AppFlavor get _currentFlavor {
    try {
      return AppConfig.active.flavor;
    } catch (_) {
      return AppFlavor.dev;
    }
  }

  /// Evaluates whether a target [LogLevel] is allowed to print in the active flavor environment.
  bool shouldLog(LogLevel level) {
    final flavor = _currentFlavor;
    switch (flavor) {
      case AppFlavor.dev:
        return true; // Dev: log everything
      case AppFlavor.stage:
        return level != LogLevel.debug; // Stage: log Info and above
      case AppFlavor.prod:
        return level == LogLevel.warning || 
               level == LogLevel.error || 
               level == LogLevel.severe; // Prod: log Warning and above
    }
  }

  /// Triggers a verbose log entry.
  void debug(String message, [Map<String, dynamic>? payload]) {
    _log(LogLevel.debug, '🔍 DEBUG', message, payload: payload);
  }

  /// Triggers a standard informational log entry.
  void info(String message, [Map<String, dynamic>? payload]) {
    _log(LogLevel.info, 'ℹ️ INFO ', message, payload: payload);
  }

  /// Triggers a warning log entry.
  void warning(String message, [Map<String, dynamic>? payload]) {
    _log(LogLevel.warning, '⚠️ WARN ', message, payload: payload);
  }

  /// Triggers a recoverable error log entry.
  void error(String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? payload]) {
    _log(LogLevel.error, '❌ ERROR', message, error: error, stackTrace: stackTrace, payload: payload);
  }

  /// Triggers a critical, severe, or unhandled crash-level log entry.
  void severe(String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? payload]) {
    _log(LogLevel.severe, '🚨 SEVERE', message, error: error, stackTrace: stackTrace, payload: payload);
  }

  /// Private dispatcher coordinating console formatting, colors, and payload layouts.
  void _log(
    LogLevel level,
    String prefix,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? payload,
  }) {
    if (!shouldLog(level)) return;

    final String timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final String baseString = '$timestamp [$prefix] [$tag]: $message';

    // Apply premium color coding matching the log severity level
    String coloredString;
    switch (level) {
      case LogLevel.debug:
        coloredString = '\x1B[36m$baseString\x1B[0m'; // Cyan
        break;
      case LogLevel.info:
        coloredString = '\x1B[32m$baseString\x1B[0m'; // Green
        break;
      case LogLevel.warning:
        coloredString = '\x1B[33m$baseString\x1B[0m'; // Yellow
        break;
      case LogLevel.error:
        coloredString = '\x1B[31m$baseString\x1B[0m'; // Red
        break;
      case LogLevel.severe:
        coloredString = '\x1B[41m\x1B[37m$baseString\x1B[0m'; // Bold Red Background, White Text
        break;
    }

    // Print the colored diagnostic line
    if (kDebugMode) {
      print(coloredString);
      
      // If structured payload exists, print formatted map parameters
      if (payload != null && payload.isNotEmpty) {
        print('\x1B[90m  └─ Payload: $payload\x1B[0m');
      }

      // If error details exist, print them
      if (error != null) {
        print('\x1B[31m  └─ Error: $error\x1B[0m');
      }

      // If stack trace exists, print formatted lines
      if (stackTrace != null) {
        print('\x1B[90m$stackTrace\x1B[0m');
      }
    }
  }
}
