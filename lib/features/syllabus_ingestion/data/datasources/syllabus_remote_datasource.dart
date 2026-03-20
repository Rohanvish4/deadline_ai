import 'dart:convert';
import 'dart:io';
import 'package:deadline_ai/core/network/api_client.dart';
import '../models/deadline_model.dart';
import 'package:file_picker/file_picker.dart';

abstract class SyllabusRemoteDataSource {
  Future<List<DeadlineModel>> extractDeadlines(PlatformFile file);
}

class SyllabusRemoteDataSourceImpl implements SyllabusRemoteDataSource {
  final ApiClient apiClient;

  SyllabusRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<DeadlineModel>> extractDeadlines(PlatformFile file) async {
    final reader = File(file.path!);
    final bytes = await reader.readAsBytes();
    final base64Pdf = base64Encode(bytes);

    final response = await apiClient.post(
      '/syllabi/upload',
      data: {
        'pdf': base64Pdf,
      },
    );

    if (response.data['status'] == 'complete') {
      final List<dynamic> deadlinesJson = response.data['deadlines'];
      return deadlinesJson.map((json) => DeadlineModel.fromJson(json)).toList();
    } else {
      throw Exception('PDF extraction failed with status: ${response.data['status']}');
    }
  }
}
