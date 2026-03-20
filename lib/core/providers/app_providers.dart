import 'package:deadline_ai/core/network/network_info.dart';
import 'package:deadline_ai/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:deadline_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:deadline_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:deadline_ai/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:deadline_ai/features/syllabus_ingestion/data/datasources/syllabus_remote_datasource.dart';
import 'package:deadline_ai/features/syllabus_ingestion/data/repositories/syllabus_repository_impl.dart';
import 'package:deadline_ai/features/syllabus_ingestion/domain/repositories/syllabus_repository.dart';
import 'package:deadline_ai/features/syllabus_ingestion/presentation/cubit/syllabus_ingestion_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProviders {
  static Future<List<SingleChildWidget>> getProviders() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    final networkInfo = NetworkInfoImpl();

    final authLocalDataSource = AuthLocalDataSourceImpl(
      sharedPreferences: sharedPreferences,
    );
    final AuthRepository authRepository = AuthRepositoryImpl(
      localDataSource: authLocalDataSource,
    );
    final authCubit = AuthCubit(authRepository: authRepository);
    await authCubit.checkAuthStatus();

    final syllabusRemoteDataSource = SyllabusRemoteDataSourceImpl();
    final SyllabusRepository syllabusRepository = SyllabusRepositoryImpl(
      remoteDataSource: syllabusRemoteDataSource,
      networkInfo: networkInfo,
    );
    final syllabusCubit = SyllabusIngestionCubit(
      syllabusRepository: syllabusRepository,
    );

    return [
      Provider<SharedPreferences>.value(value: sharedPreferences),
      Provider<FlutterSecureStorage>.value(value: secureStorage),
      Provider<NetworkInfo>.value(value: networkInfo),
      Provider<AuthRepository>.value(value: authRepository),
      Provider<SyllabusRepository>.value(value: syllabusRepository),
      BlocProvider<AuthCubit>.value(value: authCubit),
      BlocProvider<SyllabusIngestionCubit>.value(value: syllabusCubit),
    ];
  }
}
