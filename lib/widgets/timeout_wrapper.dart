import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/timeout_warning_dialog.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class TimeoutWrapper extends StatefulWidget {
  final Widget child;

  const TimeoutWrapper({
    super.key,
    required this.child,
  });

  @override
  State<TimeoutWrapper> createState() => _TimeoutWrapperState();
}

class _TimeoutWrapperState extends State<TimeoutWrapper> {
  Timer? _inactivityTimer;
  Timer? _warningTimer;
  final Duration _timeoutDuration = const Duration(minutes: 5);
  final Duration _warningDuration = const Duration(minutes: 4);
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
        _handleTimeout();
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
          _handleTimeout();
        },
      ),
    );
  }

  void _handleTimeout() {
    // if (mounted) {
    //   context.read<AuthViewModel>().logout();
    //   context.goNamed('login');
    // }
    final authViewModel = context.read<AuthViewModel>();
    authViewModel.logout().then((_) {
      if (mounted) {
        context.goNamed('login');
      }
    });
  }

  void _trackUserActivity() {
    if (!_isWarningShown) {
      _resetTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _trackUserActivity,
      onPanUpdate: (_) => _trackUserActivity(),
      child: Listener(
        onPointerDown: (_) => _trackUserActivity(),
        onPointerMove: (_) => _trackUserActivity(),
        child: widget.child,
      ),
    );
  }
} 