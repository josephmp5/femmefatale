import 'package:femmefatale/auth.dart';
import 'package:femmefatale/provider/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  Widget build(BuildContext context) {
    final chatMessages = ref.watch(chatProvider);
    final User? user = FirebaseAuth.instance.currentUser;
    final String? userId = user?.uid;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Chat with Agent",
          style: TextStyle(color: Colors.white),
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
                        decoration: InputDecoration(
                          focusColor: Colors.white,
                          hintText: "Enter your message",
                          hintStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
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
                            hasMessageBeenSent = true;
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
