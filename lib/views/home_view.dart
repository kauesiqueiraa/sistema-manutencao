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
        title: const Text('Sistema de Manutenção'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthViewModel>().logout();
              context.goNamed('login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
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
            _buildSectionHeader('Acesso Rápido'),
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
        _buildSubSection(
          context,
          title: 'Mecânicos',
          icon: Icons.group,
          onTap: () {
            context.go('/mecanicos');
          },
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context,
          title: 'Inventário de Máquinas',
          icon: Icons.inventory_2,
          onTap: () {
            // TODO: Implementar navegação para tela de inventário
          },
        ),
      ],
    );
  }

  Widget _buildSubSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
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
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
} 