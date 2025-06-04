import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../views/login_view.dart';
import '../views/home_view.dart';
import '../views/mecanicos_view.dart';
import '../widgets/timeout_wrapper.dart';
import '../viewmodels/auth_viewmodel.dart';

class AppRouter {
  static GoRouter get router => GoRouter(
        initialLocation: '/login',
        debugLogDiagnostics: true,
        routes: [
          GoRoute(
            path: '/login',
            name: 'login',
            builder: (context, state) => const LoginView(),
          ),
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => TimeoutWrapper(
              child: const HomeView(),
            ),
          ),
          GoRoute(
            path: '/mecanicos',
            name: 'mecanicos',
            builder: (context, state) => TimeoutWrapper(
              child: const MecanicosView(),
            ),
          ),
        ],
        redirect: (BuildContext context, GoRouterState state) {
          try {
            final authViewModel = context.read<AuthViewModel>();
            final isLoggedIn = authViewModel.isAuthenticated;
            final isLoginRoute = state.matchedLocation == '/login';

            if (!isLoggedIn && !isLoginRoute) {
              return '/login';
            }

            if (isLoggedIn && isLoginRoute) {
              return '/home';
            }

            return null;
          } catch (e) {
            debugPrint('Erro no redirect: $e');
            return '/login';
          }
        },
      );
} 