import 'package:flutter/material.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final bodyPartController = TextEditingController();
  final exerciseController = TextEditingController();
  final weightController = TextEditingController();
  final repsController = TextEditingController();

  final List<Map<String, dynamic>> exercises = [];
  final List<Map<String, String>> currentSets = [];

  String getTodayDate() {
    final today = DateTime.now();

    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return '${days[today.weekday - 1]} • ${today.day}/${today.month}/${today.year}';
  }

  void addSet() {
    final weight = weightController.text.trim();
    final reps = repsController.text.trim();

    if (weight.isEmpty || reps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter weight and reps')),
      );
      return;
    }

    setState(() {
      currentSets.add({
        'weight': weight,
        'reps': reps,
      });
    });

    weightController.clear();
    repsController.clear();
  }

  void saveExercise() {
    final exerciseName = exerciseController.text.trim();

    if (exerciseName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter exercise name')),
      );
      return;
    }

    if (currentSets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one set')),
      );
      return;
    }

    setState(() {
      exercises.add({
        'name': exerciseName,
        'sets': List<Map<String, String>>.from(currentSets),
      });

      exerciseController.clear();
      currentSets.clear();
    });
  }

  void saveWorkout() {
    final bodyPart = bodyPartController.text.trim();

    if (bodyPart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter body part')),
      );
      return;
    }

    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise')),
      );
      return;
    }

    Navigator.pop(context, {
      'bodyPart': bodyPart,
      'date': getTodayDate(),
      'exercises': exercises,
    });
  }

  @override
  void dispose() {
    bodyPartController.dispose();
    exerciseController.dispose();
    weightController.dispose();
    repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f3ff),
      appBar: AppBar(
        title: const Text('Add Workout'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: bodyPartController,
              decoration: InputDecoration(
                labelText: 'Body Part',
                hintText: 'Example: Chest',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: exerciseController,
              decoration: InputDecoration(
                labelText: 'Exercise Name',
                hintText: 'Example: Bench Press',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Weight',
                      hintText: 'KG',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Reps',
                      hintText: '8',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: addSet,
                icon: const Icon(Icons.add),
                label: const Text('Add Set'),
              ),
            ),
            if (currentSets.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...currentSets.asMap().entries.map((entry) {
                final index = entry.key;
                final set = entry.value;

                return ListTile(
                  title: Text('Set ${index + 1}'),
                  subtitle: Text('${set['weight']} KG × ${set['reps']} reps'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        currentSets.removeAt(index);
                      });
                    },
                  ),
                );
              }),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saveExercise,
                icon: const Icon(Icons.fitness_center),
                label: const Text('Save This Exercise'),
              ),
            ),
            const SizedBox(height: 20),
            if (exercises.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exercises Added',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...exercises.map((exercise) {
                    final sets = exercise['sets'] as List;

                    return Card(
                      child: ListTile(
                        title: Text(exercise['name']),
                        subtitle: Text('${sets.length} sets added'),
                      ),
                    );
                  }),
                ],
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saveWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Save Full Workout',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}