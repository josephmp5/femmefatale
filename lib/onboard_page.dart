import 'package:flutter/material.dart';

class OnboardPage extends StatelessWidget {
  const OnboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboard Page'),
      ),
      body: const Center(
        child: Text(
          'This is the onboard page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
