import 'dart:async';
import 'package:deadline_ai/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:deadline_ai/features/auth/presentation/cubit/auth_state.dart';
import 'package:deadline_ai/features/auth/presentation/pages/login_page.dart';
import 'package:deadline_ai/features/heatmap/presentation/pages/heatmap_page.dart';
import 'package:deadline_ai/features/home/presentation/pages/home_shell_page.dart';
import 'package:deadline_ai/features/profile/presentation/pages/profile_page.dart';
import 'package:deadline_ai/features/squad/presentation/pages/squad_page.dart';
import 'package:deadline_ai/features/syllabus_ingestion/presentation/pages/upload_syllabus_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthCubit authCubit;

  AppRouter({required this.authCubit});

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authState = authCubit.state;
      final onLogin = state.matchedLocation == '/login';
      final onSplash = state.matchedLocation == '/splash';
      final isLoading = authState is AuthInitial || authState is AuthLoading;
      final isAuthed = authState is AuthAuthenticated;

      if (isLoading && !onSplash) return '/splash';
      if (!isAuthed && !isLoading && !onLogin) return '/login';
      if (isAuthed && (onLogin || onSplash)) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeShellPage(),
      ),
      GoRoute(
        path: '/upload',
        builder: (context, state) => const UploadSyllabusPage(),
      ),
      GoRoute(
        path: '/heatmap',
        builder: (context, state) => const HeatmapPage(),
      ),
      GoRoute(
        path: '/squads',
        builder: (context, state) => const SquadPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_rounded, size: 56),
            SizedBox(height: 12),
            Text('DeadlineAI'),
            SizedBox(height: 12),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
