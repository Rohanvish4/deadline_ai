import 'package:deadline_ai/core/network/api_client.dart';
import '../models/deadline_model.dart';
import '../../domain/repositories/deadline_repository.dart';

abstract class DeadlineRemoteDataSource {
  Future<List<DeadlineModel>> getDeadlines({
    String? from,
    String? to,
    String? status,
  });

  Future<Map<String, dynamic>> confirmDeadlines(List<Map<String, dynamic>> deadlines);

  Future<List<ClashEntity>> getClashes({bool withPlan = false});

  Future<List<PaceSessionEntity>> generatePaceSessions({
    required String deadlineId,
    required double hoursPerDay,
  });
}

class DeadlineRemoteDataSourceImpl implements DeadlineRemoteDataSource {
  final ApiClient apiClient;

  DeadlineRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<DeadlineModel>> getDeadlines({
    String? from,
    String? to,
    String? status,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (status != null) queryParams['status'] = status;

    final response = await apiClient.get(
      '/deadlines',
      queryParameters: queryParams,
    );

    final List<dynamic> deadlinesJson = response.data['deadlines'];
    return deadlinesJson.map((json) => DeadlineModel.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> confirmDeadlines(List<Map<String, dynamic>> deadlines) async {
    final response = await apiClient.post(
      '/deadlines/confirm',
      data: {
        'deadlines': deadlines,
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  @override
  Future<List<ClashEntity>> getClashes({bool withPlan = false}) async {
    final response = await apiClient.get(
      '/deadlines/clashes',
      queryParameters: {'plan': withPlan.toString()},
    );

    final List<dynamic> clashJson = response.data['clashes'] as List<dynamic>;
    return clashJson
        .map(
          (item) => ClashEntity(
            deadlineA: Map<String, dynamic>.from(item['deadlineA'] as Map),
            deadlineB: Map<String, dynamic>.from(item['deadlineB'] as Map),
            daysBetween: item['daysBetween'] as int,
            combinedWeight: (item['combinedWeight'] as num).toDouble(),
            severity: item['severity'] as String,
            rescuePlan: item['rescuePlan'] == null
                ? null
                : Map<String, dynamic>.from(item['rescuePlan'] as Map),
          ),
        )
        .toList();
  }

  @override
  Future<List<PaceSessionEntity>> generatePaceSessions({
    required String deadlineId,
    required double hoursPerDay,
  }) async {
    final response = await apiClient.post(
      '/deadlines/$deadlineId/pace',
      data: {'hoursPerDay': hoursPerDay},
    );

    final List<dynamic> sessionsJson = response.data['sessions'] as List<dynamic>;
    return sessionsJson
        .map(
          (item) => PaceSessionEntity(
            sessionId: item['sessionId'] as String,
            date: item['date'] as String,
            durationHours: (item['durationHours'] as num).toDouble(),
            topic: item['topic'] as String,
            goals: ((item['goals'] as List<dynamic>?) ?? const [])
                .map((goal) => goal.toString())
                .toList(),
          ),
        )
        .toList();
  }
}
