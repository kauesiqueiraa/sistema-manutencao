import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorPage({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagem de fundo em tela cheia
        Positioned.fill(
          child: Image.asset(
            'assets/images/error.png',
            fit: BoxFit.cover,
          ),
        ),
        // Gradiente escuro para melhorar legibilidade do texto
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
        // Conteúdo centralizado
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                Text(
                  'Ops! Algo deu errado',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                // Text(
                //   message,
                //   textAlign: TextAlign.center,
                //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                //         color: Colors.white,
                //       ),
                // ),
                const SizedBox(height: 8),
                const Text(
                  'Não se preocupe, nossa equipe já foi notificada e está trabalhando para resolver o problema.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
} 