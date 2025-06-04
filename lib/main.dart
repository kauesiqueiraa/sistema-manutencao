import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sistema_manutencao/services/dio_service.dart';
import 'package:sistema_manutencao/services/mecanico_service.dart';
import 'package:sistema_manutencao/services/chamado_service.dart';
import 'package:sistema_manutencao/services/chamado_industrial_service.dart';
import 'package:sistema_manutencao/services/chamado_preventivo_service.dart';
import 'package:sistema_manutencao/viewmodels/mecanico_viewmodel.dart';
import 'package:sistema_manutencao/viewmodels/chamado_viewmodel.dart';
import 'package:sistema_manutencao/viewmodels/chamado_industrial_viewmodel.dart';
import 'package:sistema_manutencao/viewmodels/chamado_preventivo_viewmodel.dart';
import 'package:sistema_manutencao/views/mecanicos_view.dart';
import 'package:sistema_manutencao/views/chamados_predial_view.dart';
import 'package:sistema_manutencao/views/chamados_industrial_view.dart';
import 'package:sistema_manutencao/views/chamados_preventivo_view.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'widgets/timeout_wrapper.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Dio>(
          create: (_) => DioService.dio,
        ),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => MecanicoViewModel(
            MecanicoService(context.read<Dio>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ChamadoViewModel(
            ChamadoService(context.read<Dio>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ChamadoIndustrialViewModel(
            ChamadoIndustrialService(context.read<Dio>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ChamadoPreventivoViewModel(
            ChamadoPreventivoService(Dio()),
          ),
        ),
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
            GoRoute(
              path: '/mecanicos',
              name: 'mecanicos',
              builder: (context, state) => const TimeoutWrapper(
                child: MecanicosView(),
              ),
            ),
            GoRoute(
              path: '/chamados-predial',
              name: 'chamados-predial',
              builder: (context, state) => const TimeoutWrapper(
                child: ChamadosPredialView(),
              ),
            ),
            GoRoute(
              path: '/chamados-industrial',
              name: 'chamados-industrial',
              builder: (context, state) => const TimeoutWrapper(
                child: ChamadosIndustrialView(),
              ),
            ),
            GoRoute(
              path: '/chamados-preventivo',
              name: 'chamados-preventivo',
              builder: (context, state) => const ChamadosPreventivoView(),
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
