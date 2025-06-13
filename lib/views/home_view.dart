import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Manutenção', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Inter'),),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthViewModel>().logout();
              context.goNamed('login');
            },
            icon: const Icon(Icons.logout, color: Colors.white,),
          ),
        ],
        backgroundColor: const Color.fromRGBO(33, 58, 98, 1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bem-vindo ao Sistema de Manutenção',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Seção de Chamados
            _buildChamadosSection(context),
            const SizedBox(height: 32),
            // Seção de Acesso Rápido
            Row(
              children: [
                _buildSectionHeader('Acesso Rápido'),
                const SizedBox(width: 3),
                const Text(
                  'Em breve essa seção estará disponível.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
                ],
            ),
            const SizedBox(height: 16),
            _buildAcessoRapidoSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildChamadosSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chamados',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSubSection(
          context,
          title: 'Chamados Predial',
          icon: Icons.assignment,
          onTap: () {
            context.go('/chamados-predial');
          },
        ),
        const SizedBox(height: 8),
        _buildSubSection(
          context,
          title: 'Chamados Industrial',
          icon: Icons.engineering,
          onTap: () {
            context.go('/chamados-industrial');
          },
        ),
        const SizedBox(height: 8),
        _buildSubSection(
          context,
          title: 'Chamados Preventivos',
          icon: Icons.build,
          onTap: () {
            context.go('/chamados-preventivo');
          },
        ),
      ],
    );
  }

  Widget _buildAcessoRapidoSection(BuildContext context) {
    return Column(
      children: [
       _buildDisabledSubSection(
        context,
        title: 'Mecânicos',
        icon: Icons.group,
      ),
      const SizedBox(height: 12),
      _buildDisabledSubSection(
        context,
        title: 'Inventário de Máquinas',
        icon: Icons.inventory_2,
      ),
        // _buildSubSection(
        //   context,
        //   title: 'Mecânicos',
        //   icon: Icons.group,
        //   onTap: () {
        //     context.go('/mecanicos');
        //   },
        // ),
        // const SizedBox(height: 12),
        // _buildSubSection(
        //   context,
        //   title: 'Inventário de Máquinas',
        //   icon: Icons.inventory_2,
        //   onTap: () {
        //     // TODO: Implementar navegação para tela de inventário
        //   },
        // ),
      ],
    );
  }

  Widget _buildSubSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [
          //     Colors.blue.shade50,
          //     Colors.blue.shade100,
          //   ],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledSubSection(
  BuildContext context, {
  required String title,
  required IconData icon,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      IgnorePointer(
        child: Opacity(
          opacity: 0.5,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.lock_outline),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Em breve',
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
      const SizedBox(height: 12),
    ],
  );
}
} 