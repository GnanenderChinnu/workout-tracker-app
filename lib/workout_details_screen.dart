import 'package:flutter/material.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> workout;
  final ValueChanged<Map<String, dynamic>> onWorkoutChanged;
  final List<Map<String, dynamic>> Function(String exerciseName)
      getExerciseHistory;

  const WorkoutDetailsScreen({
    super.key,
    required this.workout,
    required this.onWorkoutChanged,
    required this.getExerciseHistory,
  });

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  late Map<String, dynamic> workout;
  int? editingExerciseIndex;

  final weightController = TextEditingController();
  final repsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    workout = Map<String, dynamic>.from(widget.workout);
    workout['exercises'] = (widget.workout['exercises'] as List)
        .map((exercise) => Map<String, dynamic>.from(exercise))
        .toList();
  }

  void autoSave() {
    widget.onWorkoutChanged(workout);
  }

  List get exercises => workout['exercises'] as List;

  void toggleEditMode(int index) {
    setState(() {
      editingExerciseIndex = editingExerciseIndex == index ? null : index;
      weightController.clear();
      repsController.clear();
    });
  }

  void addExerciseWithSet() {
    final exerciseController = TextEditingController();
    final weightController = TextEditingController();
    final repsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: exerciseController,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  hintText: 'Example: Bench Press',
                ),
              ),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  hintText: 'KG',
                ),
              ),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Reps',
                  hintText: '8',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = exerciseController.text.trim();
                final weight = weightController.text.trim();
                final reps = repsController.text.trim();

                if (name.isEmpty || weight.isEmpty || reps.isEmpty) return;

                setState(() {
                  exercises.add({
                    'name': name,
                    'sets': [
                      {
                        'weight': weight,
                        'reps': reps,
                      }
                    ],
                  });
                });

                autoSave();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void renameExercise(int index) {
    final controller = TextEditingController(text: exercises[index]['name']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Exercise'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Exercise Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedName = controller.text.trim();
                if (updatedName.isEmpty) return;

                setState(() {
                  exercises[index]['name'] = updatedName;
                });

                autoSave();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });

    autoSave();
  }

  void addSet(int exerciseIndex) {
    final weight = weightController.text.trim();
    final reps = repsController.text.trim();

    if (weight.isEmpty || reps.isEmpty) return;

    setState(() {
      final sets = exercises[exerciseIndex]['sets'] as List;
      sets.add({'weight': weight, 'reps': reps});
      weightController.clear();
      repsController.clear();
    });

    autoSave();
  }

  void editSet(int exerciseIndex, int setIndex) {
    final sets = exercises[exerciseIndex]['sets'] as List;
    final selectedSet = sets[setIndex];

    final weightEditController =
        TextEditingController(text: selectedSet['weight']);
    final repsEditController = TextEditingController(text: selectedSet['reps']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Set'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightEditController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight'),
              ),
              TextField(
                controller: repsEditController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reps'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final weight = weightEditController.text.trim();
                final reps = repsEditController.text.trim();

                if (weight.isEmpty || reps.isEmpty) return;

                setState(() {
                  sets[setIndex] = {
                    'weight': weight,
                    'reps': reps,
                  };
                });

                autoSave();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteSet(int exerciseIndex, int setIndex) {
    setState(() {
      final sets = exercises[exerciseIndex]['sets'] as List;
      sets.removeAt(setIndex);
    });

    autoSave();
  }

  void showExerciseHistory(String exerciseName) {
    final history = widget.getExerciseHistory(exerciseName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$exerciseName History',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: history.isEmpty
                    ? const Center(
                        child: Text(
                          'No previous history found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index];
                          final sets = item['sets'] as List;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['date'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['bodyPart'],
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 10),
                                  ...sets.asMap().entries.map((entry) {
                                    final setIndex = entry.key;
                                    final set = entry.value;

                                    return Text(
                                      'Set ${setIndex + 1}: ${set['weight']} KG × ${set['reps']} reps',
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyPart = workout['bodyPart'];
    final date = workout['date'];

    return Scaffold(
      backgroundColor: const Color(0xfff5f3ff),
      appBar: AppBar(
        title: const Text('Workout Details'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Color(0xff7b61ff)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Body Part',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    bodyPart,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    date,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Exercises',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: addExerciseWithSet,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, exerciseIndex) {
                  final exercise = exercises[exerciseIndex];
                  final sets = exercise['sets'] as List;
                  final isEditing = editingExerciseIndex == exerciseIndex;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  exercise['name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  showExerciseHistory(exercise['name']);
                                },
                                icon: const Icon(
                                  Icons.history,
                                  color: Colors.orange,
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'rename',
                                    child: Text('Rename'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'rename') {
                                    renameExercise(exerciseIndex);
                                  } else if (value == 'delete') {
                                    deleteExercise(exerciseIndex);
                                  }
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  toggleEditMode(exerciseIndex);
                                },
                                icon: Icon(
                                  isEditing ? Icons.check_circle : Icons.edit,
                                  color: isEditing
                                      ? Colors.green
                                      : Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...sets.asMap().entries.map((entry) {
                            final setIndex = entry.key;
                            final set = entry.value;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xfff5f3ff),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Set ${setIndex + 1}: ${set['weight']} KG × ${set['reps']} reps',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  if (isEditing)
                                    TextButton(
                                      onPressed: () {
                                        editSet(exerciseIndex, setIndex);
                                      },
                                      child: const Text('Edit'),
                                    ),
                                  if (isEditing)
                                    TextButton(
                                      onPressed: () {
                                        deleteSet(exerciseIndex, setIndex);
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                          if (isEditing) ...[
                            const SizedBox(height: 12),
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
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  addSet(exerciseIndex);
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add New Set'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}