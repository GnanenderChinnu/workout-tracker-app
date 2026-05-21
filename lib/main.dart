import 'package:flutter/material.dart';

void main() {
  runApp(const WorkoutTrackerApp());
}

class WorkoutTrackerApp extends StatelessWidget {
  const WorkoutTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Tracker',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text('Workout Tracker'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Welcome to your workout tracker',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('Today’s Workout'),
                subtitle: const Text('No workout added yet'),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                print('Add Workout button clicked');
              },
              child: const Text('Add Workout'),
            ),
          ],
        ),
      ),
    );
  }
}