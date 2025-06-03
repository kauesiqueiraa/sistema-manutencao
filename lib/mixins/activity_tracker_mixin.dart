import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/timeout_warning_dialog.dart';

mixin ActivityTrackerMixin<T extends StatefulWidget> on State<T> {
  Timer? _inactivityTimer;
  Timer? _warningTimer;
  final Duration _timeoutDuration = const Duration(minutes: 5);
  final Duration _warningDuration = const Duration(minutes: 4);
  VoidCallback? onTimeout;
  bool _isWarningShown = false;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _warningTimer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _warningTimer?.cancel();
    _isWarningShown = false;

    _warningTimer = Timer(_warningDuration, () {
      if (mounted && !_isWarningShown) {
        _showWarningDialog();
      }
    });

    _inactivityTimer = Timer(_timeoutDuration, () {
      if (mounted && !_isWarningShown) {
        onTimeout?.call();
      }
    });
  }

  void _showWarningDialog() {
    _isWarningShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TimeoutWarningDialog(
        onStayLoggedIn: () {
          _isWarningShown = false;
          Navigator.of(context).pop();
          _resetTimer();
        },
        onLogout: () {
          Navigator.of(context).pop();
          onTimeout?.call();
        },
      ),
    );
  }

  void trackUserActivity() {
    if (!_isWarningShown) {
      _resetTimer();
    }
  }
} 