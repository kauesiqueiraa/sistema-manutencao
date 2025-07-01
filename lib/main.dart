import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sistema_manutencao/services/auth_service.dart';
import 'package:sistema_manutencao/services/dio_service.dart';
import 'package:sistema_manutencao/services/inventory_service.dart';
import 'package:sistema_manutencao/services/mecanico_service.dart';
import 'package:sistema_manutencao/services/chamado_predial_service.dart';
import 'package:sistema_manutencao/services/chamado_industrial_service.dart';
import 'package:sistema_manutencao/services/chamado_preventivo_service.dart';
import 'package:sistema_manutencao/services/user_service.dart';
import 'package:sistema_manutencao/services/produto_service.dart';
import 'package:sistema_manutencao/viewmodels/inventory_viewmodel.dart';
import 'package:sistema_manutencao/viewmodels/mecanico_viewmodel.dart';
import 'package:sistema_manutencao/viewmodels/chamado_predial_viewmodel.dart';
import 'package:sistema_manutencao/viewmodels/chamado_industrial_viewmodel.dart';
import 'package:sistema_manutencao/viewmodels/chamado_preventivo_viewmodel.dart';
import 'package:sistema_manutencao/viewmodels/produto_viewmodel.dart';
import 'package:sistema_manutencao/views/inventory_view.dart';
import 'package:sistema_manutencao/views/mecanicos_view.dart';
import 'package:sistema_manutencao/views/chamados_predial_view.dart';
import 'package:sistema_manutencao/views/chamados_industrial_view.dart';
import 'package:sistema_manutencao/views/chamados_preventivo_view.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'widgets/timeout_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final dio = Dio();
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  runApp(
    MultiProvider(
      providers: [
        Provider<Dio>(
          create: (_) => dio,
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<UserService>(
          create: (_) => UserService(),
        ),
        Provider<MecanicoService>(
          create: (_) => MecanicoService(),
        ),
        Provider<ChamadoPredialService>(
          create: (_) => ChamadoPredialService(),
        ),
        Provider<ChamadoIndustrialService>(
          create: (context) => ChamadoIndustrialService(),
        ),
        Provider<ChamadoPreventivoService>(
          create: (context) => ChamadoPreventivoService(),
        ),
        Provider<ProdutoService>(
          create: (context) => ProdutoService(),
        ),
        ChangeNotifierProxyProvider2<AuthService, UserService, AuthViewModel>(
          create: (context) => AuthViewModel(
            context.read<AuthService>(),
            context.read<UserService>(),
            context.read<MecanicoService>(),
          ),
          update: (context, authService, userService, previous) => AuthViewModel(
            authService,
            userService,
            context.read<MecanicoService>(),
          ),
        ),
        ChangeNotifierProxyProvider2<ChamadoPredialService, MecanicoService, ChamadoPredialViewModel>(
          create: (context) => ChamadoPredialViewModel(
            context.read<ChamadoPredialService>(),
            context.read<MecanicoService>(),
          ),
          update: (context, service, mecanicoService, previous) => ChamadoPredialViewModel(
            service,
            mecanicoService,
          ),
        ),
        ChangeNotifierProvider<ChamadoIndustrialViewModel>(
          create: (context) => ChamadoIndustrialViewModel(
            context.read<ChamadoIndustrialService>(),
            context.read<MecanicoService>(),
          ),
        ),
        ChangeNotifierProvider<ChamadoPreventivoViewModel>(
          create: (context) => ChamadoPreventivoViewModel(
            context.read<ChamadoPreventivoService>(),
            context.read<ProdutoService>(),
          ),
        ),
        ChangeNotifierProvider<MecanicoViewModel>(
          create: (context) => MecanicoViewModel(
            context.read<MecanicoService>(),
          ),
        ),
        ChangeNotifierProvider<ProdutoViewModel>(
          create: (context) => ProdutoViewModel(
            context.read<ProdutoService>(),
          ),
        ),
        ChangeNotifierProvider<InventoryViewmodel>(
          create: (context) => InventoryViewmodel(
            InventoryService(),
          ),
        )
      ],
      child: const MyApp(),
    ),
  );
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
          create: (context) => AuthViewModel(
            AuthService(),
            UserService(),
            MecanicoService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => MecanicoViewModel(
            MecanicoService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ChamadoPredialViewModel(
            ChamadoPredialService(),
            MecanicoService(),
      
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ChamadoIndustrialViewModel(
            ChamadoIndustrialService(),
            // ChamadoIndustrialService(context.read<Dio>(), context.read<MecanicoService>()),
            MecanicoService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ChamadoPreventivoViewModel(
            ChamadoPreventivoService(),
            ProdutoService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProdutoViewModel(
            ProdutoService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => InventoryViewmodel(
            InventoryService(),
          ),
        )
      ],
      child: MaterialApp.router(
        title: 'Sistema de Manutenção',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: GoRouter(
          initialLocation: '/login',
          refreshListenable: context.read<AuthViewModel>(),
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
              path: '/inventario-maquinas',
              name: 'inventario-maquinas',
              builder: (context, state) => const TimeoutWrapper(
                child: InventoryView(),
                // child: InventarioMaquinasView(),
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
            final authViewModel = context.read<AuthViewModel>();
            final isAuthenticated = authViewModel.isAuthenticated;
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
