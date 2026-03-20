import 'dart:convert';

import 'package:deadline_ai/core/network/api_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SquadRemoteDataSource {
  final ApiClient apiClient;
  final String webSocketBaseUrl;
  WebSocketChannel? _channel;

  SquadRemoteDataSource({
    required this.apiClient,
    required this.webSocketBaseUrl,
  });

  Future<Map<String, dynamic>> createSquad(String name) async {
    final response = await apiClient.post('/squads', data: {'name': name});
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> joinSquad(String inviteCode) async {
    final response = await apiClient.post('/squads/join', data: {'inviteCode': inviteCode});
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Map<String, dynamic>>> listSquads() async {
    final response = await apiClient.get('/squads');
    final List<dynamic> squads = response.data['squads'] as List<dynamic>;
    return squads.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> getSquadBoard(String squadId) async {
    final response = await apiClient.get('/squads/$squadId');
    final List<dynamic> board = response.data['board'] as List<dynamic>;
    return board.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<void> leaveSquad(String squadId) async {
    await apiClient.delete('/squads/$squadId');
  }

  Stream<dynamic> connectToSquad({
    required String userId,
    required String squadId,
  }) {
    final uri = Uri.parse('$webSocketBaseUrl?userId=$userId&squadId=$squadId');
    _channel?.sink.close();
    _channel = WebSocketChannel.connect(uri);
    return _channel!.stream;
  }

  void sendBroadcast(Map<String, dynamic> data) {
    _channel?.sink.add(
      jsonEncode({
        'action': 'broadcast',
        'data': data,
      }),
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
