import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'widgets/timeout_wrapper.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp.router(
        title: 'Sistema de Manutenção',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: GoRouter(
          initialLocation: '/login',
          routes: [
            GoRoute(
              path: '/login',
              name: 'login',
              builder: (context, state) => const LoginView(),
            ),
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const TimeoutWrapper(
                child: HomeView(),
              ),
            ),
          ],
          redirect: (context, state) {
            final isAuthenticated = context.read<AuthViewModel>().isAuthenticated;
            final isLoginRoute = state.matchedLocation == '/login';

            if (!isAuthenticated && !isLoginRoute) {
              return '/login';
            }

            if (isAuthenticated && isLoginRoute) {
              return '/home';
            }

            return null;
          },
        ),
      ),
    );
  }
}
