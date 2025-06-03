import 'package:flutter/material.dart';

class TimeoutWarningDialog extends StatelessWidget {
  final VoidCallback onStayLoggedIn;
  final VoidCallback onLogout;

  const TimeoutWarningDialog({
    super.key,
    required this.onStayLoggedIn,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sessão Expirando'),
      content: const Text(
        'Sua sessão irá expirar em 1 minuto. Deseja continuar logado?',
      ),
      actions: [
        TextButton(
          onPressed: onLogout,
          child: const Text('Sair'),
        ),
        TextButton(
          onPressed: onStayLoggedIn,
          child: const Text('Continuar'),
        ),
      ],
    );
  }
} 