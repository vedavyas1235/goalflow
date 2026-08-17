import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goalflow/theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your Consistency',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 32),
            
            // Circular Progress Mock
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: 0.82, // 82% from PDF example
                      strokeWidth: 16,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '82%',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48),
                      ),
                      Text(
                        'Monthly',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Weekly Progress Mock
            Text('This Week', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              value: 5/6, // 5 out of 6 planned actions
              minHeight: 12,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            const SizedBox(height: 8),
            const Text('5 / 6 planned actions completed', textAlign: TextAlign.center),
            
            const SizedBox(height: 48),
            
            ElevatedButton(
              onPressed: () => context.push('/reflection'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
              child: const Text('Do Weekly Reflection'),
            )
          ],
        ),
      ),
    );
  }
}
