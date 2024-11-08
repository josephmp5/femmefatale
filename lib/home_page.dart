import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:femmefatale/provider/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/models/purchases_configuration.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _controller = TextEditingController();
  bool hasMessageBeenSent = false;
  bool isLoading = false;

  // List of predefined questions
  final List<String> questions = [
    "How can I build more confidence when talking to someone I like?",
    "What are some ways to get over a breakup faster?",
    "How do I know if someone is really interested in me?",
    "What should I do if I'm feeling insecure in my relationship?",
    "How can I start a meaningful conversation on a first date?"
  ];

  Future<void> _configureSDK() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;

    if (Platform.isAndroid) {
      // Add your Android configuration here
    } else if (Platform.isIOS) {
      configuration =
          PurchasesConfiguration("appl_weqNoJwAvWxZVdtvLpyyVFayMux");
    }

    if (configuration != null) {
      await Purchases.configure(configuration);

      final paywallResult =
          await RevenueCatUI.presentPaywallIfNeeded("premium");
      debugPrint('Paywall result: $paywallResult');

      if (paywallResult == PaywallResult.purchased) {
        await _updateTokenCount();
      }
    }
  }

  Future<void> _updateTokenCount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      int currentTokenCount = userDoc['tokens'] ?? 0;
      int tokenIncrement;

      // Retrieve customer info to check what was purchased
      final customerInfo = await Purchases.getCustomerInfo();

      // Assuming you want to check all active entitlements (like in `HomeScreen`)
      if (customerInfo.entitlements.active.isNotEmpty) {
        for (var entitlement in customerInfo.entitlements.active.values) {
          final productId = entitlement.productIdentifier;

          // Use the same logic as in HomeScreen for assigning token amounts
          if (productId == "femmelilith_30days_999") {
            tokenIncrement = 50;
          } else if (productId == "femmelilith_90days_1999") {
            tokenIncrement = 75;
          } else if (productId == "femmelilith_annual_7999") {
            tokenIncrement = 600;
          } else {
            tokenIncrement = 0; // default or handle unknown product identifier
          }

          // Update token count
          int newTokenCount = currentTokenCount + tokenIncrement;

          // Update Firestore with the new token count
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'tokens': newTokenCount,
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatMessages = ref.watch(chatProvider);
    final User? user = FirebaseAuth.instance.currentUser;
    final String? userId = user?.uid;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: GestureDetector(
          onTap: _configureSDK,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.star,
                color: Colors.yellow,
                size: 24.0,
              ),
              SizedBox(width: 8.0),
              Text(
                "Try Premium",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFBA55D3),
              Color(0xFF9370DB),
              Color(0xFFC71585),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: chatMessages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < chatMessages.length) {
                      final message = chatMessages[index];
                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? Colors.blue
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color:
                                  message.isUser ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Display loading indicator where the response will be
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.purple),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: !hasMessageBeenSent
                    ? Column(
                        key:
                            const ValueKey<int>(1), // Unique key for transition
                        children: questions
                            .map((question) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _controller.text =
                                          question; // Set question in text field
                                    });
                                  },
                                  child: Card(
                                    color: const Color(0xFF800000),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(
                                        child: Text(
                                          question,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      )
                    : const SizedBox.shrink(), // Empty widget if no questions
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(
                            color:
                                Colors.white), // User text color in TextField
                        decoration: InputDecoration(
                          hintText: "Enter your message",
                          hintStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            borderSide: const BorderSide(
                                color: Colors.white, width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final message = _controller.text.trim();
                        if (message.isNotEmpty) {
                          // Remove questions as soon as user sends a message
                          setState(() {
                            isLoading =
                                true; // Start loading when message is sent
                          });

                          // Using ref to read and call addAgentResponse method
                          await ref
                              .read(chatProvider.notifier)
                              .addAgentResponse(message, userId!, context);

                          // Stop loading after response is received
                          setState(() {
                            isLoading = false;
                            hasMessageBeenSent = true;
                          });

                          _controller.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
