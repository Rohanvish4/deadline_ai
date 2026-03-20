import 'package:deadline_ai/core/network/api_client.dart';

abstract class AutopsyRemoteDataSource {
  Future<Map<String, dynamic>> submitAutopsy({
    required String deadlineId,
    required bool completedOnTime,
    required int satisfaction,
    String? whatWentWell,
    String? whatWentWrong,
    String? lessonsLearned,
    bool? wouldChangeApproach,
    double? hoursSpent,
    int? startedDaysBefore,
  });
}

class AutopsyRemoteDataSourceImpl implements AutopsyRemoteDataSource {
  final ApiClient apiClient;

  AutopsyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> submitAutopsy({
    required String deadlineId,
    required bool completedOnTime,
    required int satisfaction,
    String? whatWentWell,
    String? whatWentWrong,
    String? lessonsLearned,
    bool? wouldChangeApproach,
    double? hoursSpent,
    int? startedDaysBefore,
  }) async {
    final response = await apiClient.post(
      '/autopsies',
      data: {
        'deadlineId': deadlineId,
        'completedOnTime': completedOnTime,
        'satisfaction': satisfaction,
        'whatWentWell': whatWentWell,
        'whatWentWrong': whatWentWrong,
        'lessonsLearned': lessonsLearned,
        'wouldChangeApproach': wouldChangeApproach,
        'hoursSpent': hoursSpent,
        'startedDaysBefore': startedDaysBefore,
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }
}
