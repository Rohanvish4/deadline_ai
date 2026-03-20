import 'package:deadline_ai/core/network/api_client.dart';
import 'package:deadline_ai/core/network/network_info.dart';
import 'package:deadline_ai/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:deadline_ai/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:deadline_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:deadline_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:deadline_ai/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:deadline_ai/features/deadlines/data/datasources/deadline_remote_datasource.dart';
import 'package:deadline_ai/features/deadlines/data/repositories/deadline_repository_impl.dart';
import 'package:deadline_ai/features/deadlines/domain/repositories/deadline_repository.dart';
import 'package:deadline_ai/features/deadlines/presentation/cubit/deadline_cubit.dart';
import 'package:deadline_ai/features/heatmap/data/datasources/autopsy_remote_datasource.dart';
import 'package:deadline_ai/features/heatmap/data/repositories/autopsy_repository_impl.dart';
import 'package:deadline_ai/features/heatmap/domain/repositories/autopsy_repository.dart';
import 'package:deadline_ai/features/heatmap/presentation/cubit/autopsy_cubit.dart';
import 'package:deadline_ai/features/squad/data/datasources/squad_remote_datasource.dart';
import 'package:deadline_ai/features/squad/data/repositories/squad_repository_impl.dart';
import 'package:deadline_ai/features/squad/domain/repositories/squad_repository.dart';
import 'package:deadline_ai/features/squad/presentation/cubit/squad_cubit.dart';
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

    const baseUrl = String.fromEnvironment(
      'DEADLINEAI_API_BASE_URL',
      defaultValue: 'https://3bc2adz71l.execute-api.ap-south-1.amazonaws.com/prod',
    );
    const wsUrl = String.fromEnvironment(
      'DEADLINEAI_WS_BASE_URL',
      defaultValue: 'wss://ejargnnn59.execute-api.ap-south-1.amazonaws.com/prod',
    );
    const cognitoUserPoolId = String.fromEnvironment(
      'DEADLINEAI_COGNITO_USER_POOL_ID',
      defaultValue: 'ap-south-1_mjXWkUbJy',
    );
    const cognitoClientId = String.fromEnvironment(
      'DEADLINEAI_COGNITO_CLIENT_ID',
      defaultValue: '7osd2snumuo3kqit8ke0bcgpr0',
    );

    final apiClient = ApiClient(baseUrl: baseUrl);

    final authLocalDataSource = AuthLocalDataSourceImpl(
      sharedPreferences: sharedPreferences,
    );
    final authRemoteDataSource = AuthRemoteDataSource(
      userPoolId: cognitoUserPoolId,
      clientId: cognitoClientId,
    );
    final AuthRepository authRepository = AuthRepositoryImpl(
      localDataSource: authLocalDataSource,
      remoteDataSource: authRemoteDataSource,
    );
    final authCubit = AuthCubit(
      authRepository: authRepository,
      apiClient: apiClient,
    );
    await authCubit.checkAuthStatus();

    final syllabusRemoteDataSource = SyllabusRemoteDataSourceImpl(
      apiClient: apiClient,
    );
    final SyllabusRepository syllabusRepository = SyllabusRepositoryImpl(
      remoteDataSource: syllabusRemoteDataSource,
      networkInfo: networkInfo,
    );
    final syllabusCubit = SyllabusIngestionCubit(
      syllabusRepository: syllabusRepository,
    );

    final deadlineRemoteDataSource = DeadlineRemoteDataSourceImpl(
      apiClient: apiClient,
    );
    final DeadlineRepository deadlineRepository = DeadlineRepositoryImpl(
      remoteDataSource: deadlineRemoteDataSource,
      networkInfo: networkInfo,
    );
    final deadlineCubit = DeadlineCubit(deadlineRepository: deadlineRepository);

    final autopsyRemoteDataSource = AutopsyRemoteDataSourceImpl(apiClient: apiClient);
    final AutopsyRepository autopsyRepository = AutopsyRepositoryImpl(
      remoteDataSource: autopsyRemoteDataSource,
      networkInfo: networkInfo,
    );
    final autopsyCubit = AutopsyCubit(autopsyRepository: autopsyRepository);

    final squadRemoteDataSource = SquadRemoteDataSource(
      apiClient: apiClient,
      webSocketBaseUrl: wsUrl,
    );
    final SquadRepository squadRepository = SquadRepositoryImpl(
      remoteDataSource: squadRemoteDataSource,
      networkInfo: networkInfo,
    );
    final squadCubit = SquadCubit(
      squadRepository: squadRepository,
      squadRemoteDataSource: squadRemoteDataSource,
      authCubit: authCubit,
    );

    return [
      Provider<SharedPreferences>.value(value: sharedPreferences),
      Provider<FlutterSecureStorage>.value(value: secureStorage),
      Provider<NetworkInfo>.value(value: networkInfo),
      Provider<ApiClient>.value(value: apiClient),
      Provider<AuthRepository>.value(value: authRepository),
      Provider<SyllabusRepository>.value(value: syllabusRepository),
      Provider<DeadlineRepository>.value(value: deadlineRepository),
      Provider<AutopsyRepository>.value(value: autopsyRepository),
      Provider<SquadRepository>.value(value: squadRepository),
      BlocProvider<AuthCubit>.value(value: authCubit),
      BlocProvider<SyllabusIngestionCubit>.value(value: syllabusCubit),
      BlocProvider<DeadlineCubit>.value(value: deadlineCubit),
      BlocProvider<AutopsyCubit>.value(value: autopsyCubit),
      BlocProvider<SquadCubit>.value(value: squadCubit),
    ];
  }
}
