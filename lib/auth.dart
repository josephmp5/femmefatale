import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:femmefatale/constants.dart';
import 'package:femmefatale/home_page.dart';
import 'package:femmefatale/main.dart';
import 'package:femmefatale/onboard_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;

final authProvider = Provider((ref) => Auth());

final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> signInAnonymously({required BuildContext context}) async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          'uid': user.uid,
          'tokens': 25,
        });

        await MyApp.navigatorKey.currentState?.pushReplacement(PageTransition(
          child: const HomePage(),
          type: PageTransitionType.rightToLeft,
        ));
      } else {
        const Center(
          child: Text("error when making it "),
        );
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  final String baseUrl =
      "https://api.openai.com/v1/chat/completions"; // OpenAI API endpoint

  Future<String> getAgentResponse(
      String userMessage, String userId, BuildContext context) async {
    try {
      // Step 1: Check if user has tokens
      var docRef = _db.collection('users').doc(userId);
      var doc = await docRef.get();

      if (doc.exists) {
        int tokens = doc.data()?['tokens'] ?? 0;
        if (tokens <= 0) {
          // Step 2: Show snackbar if no tokens are available
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No tokens left. Please buy more tokens.'),
            ),
          );
          return 'No tokens left.';
        }

        // Step 3: Deduct one token
        await docRef.update({
          'tokens': FieldValue.increment(-1),
        });
      } else {
        // If user document does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found. Please try again.'),
          ),
        );
        return 'User not found.';
      }

      // Step 4: Make API request to OpenAI
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization':
              'Bearer ${Constants.uri}', // Replace with your valid API key
        },
        body: jsonEncode({
          'model':
              'gpt-4o-mini-2024-07-18', // Replace with the model you want to use
          'messages': [
            {
              'role': 'system',
              'content':
                  "You are an AI assistant that provides relationship advice like a friendly, supportive sister. Follow these guidelines:\n- Be Brief: Keep responses to three to four sentences. Be clear and direct.\n- Tone: Friendly, casual, non-judgmental, like talking to a trusted sister.\n- Empathy First: Validate the user's feelings briefly.\n- Encouraging: Offer short, gentle encouragement. Avoid lengthy explanations.\n- Relatable Style: Use 'sisterly' phrases like 'I’ve been there, sis' or 'trust me,' but keep it brief.\n- Actionable Steps: Give one or two simple, practical steps that are easy to follow.\n- Build Continuity: Personalize based on the user's past details but keep it concise."
            },
            {'role': 'user', 'content': userMessage}
          ],
          'temperature': 0.8,
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final data =
            json.decode(response.body)['choices'][0]['message']['content'];
        String sanitizedText =
            data.toString().replaceAll(RegExp(r'[^\x00-\x7F]'), '');
        return sanitizedText;
      } else {
        throw Exception('Failed to get response from agent');
      }
    } catch (e) {
      print("Error: $e");
      return 'Error getting response';
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardPage()),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to signout: $e');
    }
  }
}
