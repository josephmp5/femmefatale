import 'package:femmefatale/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Message {
  final String text;
  final bool isUser;

  Message(this.text, this.isUser);
}

class ChatNotifier extends StateNotifier<List<Message>> {
  ChatNotifier() : super([]);

  final Auth _agentService = Auth();

  void addUserMessage(String message) {
    state = [
      ...state,
      Message(message, true),
    ];
  }

  Future<void> addAgentResponse(
      String userMessage, String userId, BuildContext context) async {
    addUserMessage(userMessage);

    final agentResponse =
        await _agentService.getAgentResponse(userMessage, userId, context);
    state = [
      ...state,
      Message(agentResponse, false),
    ];
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>((ref) {
  return ChatNotifier();
});
