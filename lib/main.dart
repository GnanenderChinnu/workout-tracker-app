import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'add_workout_screen.dart';
import 'workout_details_screen.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(
    android: androidSettings,
  );

  await notificationsPlugin.initialize(initializationSettings);

  runApp(const WorkoutTrackerApp());
}

class WorkoutTrackerApp extends StatefulWidget {
  const WorkoutTrackerApp({super.key});

  @override
  State<WorkoutTrackerApp> createState() =>
      _WorkoutTrackerAppState();
}

class _WorkoutTrackerAppState
    extends State<WorkoutTrackerApp> {
  bool isDarkMode = false;

  void updateTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Tracker',
      debugShowCheckedModeBanner: false,

      themeMode:
          isDarkMode ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),

      home: HomeScreen(
        isDarkMode: isDarkMode,
        onThemeChanged: updateTheme,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> workouts = [];

  int selectedIndex = 0;

  String searchQuery = '';

  TimeOfDay? reminderTime;

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData =
        prefs.getString('workouts');

    final savedReminder =
        prefs.getString('reminderTime');

    final savedDarkMode =
        prefs.getBool('darkMode') ?? false;

    if (savedData != null) {
      final decodedData =
          jsonDecode(savedData) as List;

      workouts = decodedData
          .map(
            (item) =>
                Map<String, dynamic>.from(item),
          )
          .toList();
    }

    if (savedReminder != null) {
      final parts = savedReminder.split(':');

      reminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    widget.onThemeChanged(savedDarkMode);

    setState(() {});
  }

  Future<void> saveWorkouts() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'workouts',
      jsonEncode(workouts),
    );
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('darkMode', value);

    widget.onThemeChanged(value);
  }

  Future<void> scheduleWorkoutReminder(
    TimeOfDay time,
  ) async {
    await notificationsPlugin.cancelAll();

    final now = DateTime.now();

    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate =
          scheduledDate.add(
        const Duration(days: 1),
      );
    }

    await notificationsPlugin.zonedSchedule(
      0,
      'Workout Reminder 💪',
      'Time to train and beat your last workout!',
      tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_channel',
          'Workout Notifications',
          channelDescription:
              'Workout reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time,
    );
  }

  Future<void> saveReminder(
    TimeOfDay time,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'reminderTime',
      '${time.hour}:${time.minute}',
    );

    setState(() {
      reminderTime = time;
    });

    await scheduleWorkoutReminder(time);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Workout reminder set at ${time.format(context)}',
          ),
        ),
      );
    }
  }

  void addWorkout(
    Map<String, dynamic> workout,
  ) {
    setState(() {
      workouts.add(workout);
    });

    saveWorkouts();
  }

  void updateWorkout(
    int index,
    Map<String, dynamic> updatedWorkout,
  ) {
    setState(() {
      workouts[index] = updatedWorkout;
    });

    saveWorkouts();
  }

  void deleteWorkout(int index) {
    setState(() {
      workouts.removeAt(index);
    });

    saveWorkouts();
  }

  int getTotalSets(
    Map<String, dynamic> workout,
  ) {
    int total = 0;

    final exercises =
        workout['exercises'] as List;

    for (var exercise in exercises) {
      total +=
          (exercise['sets'] as List).length;
    }

    return total;
  }

  int getTotalExercises() {
    int total = 0;

    for (var workout in workouts) {
      total +=
          (workout['exercises'] as List)
              .length;
    }

    return total;
  }

  int getAllTotalSets() {
    int total = 0;

    for (var workout in workouts) {
      total += getTotalSets(workout);
    }

    return total;
  }

  String getStrongestLift() {
    double maxWeight = 0;

    String exerciseName =
        'No lifts yet';

    for (var workout in workouts) {
      final exercises =
          workout['exercises'] as List;

      for (var exercise in exercises) {
        final sets =
            exercise['sets'] as List;

        for (var set in sets) {
          final weight =
              double.tryParse(
                    set['weight']
                        .toString(),
                  ) ??
                  0;

          if (weight > maxWeight) {
            maxWeight = weight;

            exerciseName =
                '${exercise['name']} - ${weight.toStringAsFixed(0)} KG';
          }
        }
      }
    }

    return exerciseName;
  }

  List<Map<String, dynamic>>
      getExerciseHistory(
    String exerciseName,
    int currentWorkoutIndex,
  ) {
    final history =
        <Map<String, dynamic>>[];

    for (
      int i = 0;
      i < workouts.length;
      i++
    ) {
      if (i == currentWorkoutIndex) {
        continue;
      }

      final workout = workouts[i];

      final exercises =
          workout['exercises'] as List;

      for (var exercise in exercises) {
        if (exercise['name']
                .toString()
                .toLowerCase()
                .trim() ==
            exerciseName
                .toLowerCase()
                .trim()) {
          history.add({
            'bodyPart':
                workout['bodyPart'],
            'date': workout['date'],
            'sets': exercise['sets'],
          });
        }
      }
    }

    return history.reversed.toList();
  }

  List<Map<String, dynamic>>
      getFilteredWorkouts() {
    if (searchQuery.trim().isEmpty) {
      return workouts;
    }

    final query =
        searchQuery.toLowerCase();

    return workouts.where((workout) {
      final bodyPart =
          workout['bodyPart']
              .toString()
              .toLowerCase();

      final date = workout['date']
          .toString()
          .toLowerCase();

      final exercises =
          workout['exercises'] as List;

      final exerciseMatch =
          exercises.any(
        (exercise) => exercise['name']
            .toString()
            .toLowerCase()
            .contains(query),
      );

      return bodyPart.contains(query) ||
          date.contains(query) ||
          exerciseMatch;
    }).toList();
  }

  Widget buildDashboard() {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.all(16),

      child: Column(
        children: [
          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.all(24),

            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Colors.deepPurple,
                  Color(0xff7b61ff),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(24),
            ),

            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Today’s Goal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'Beat Your Last Workout 💪',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: buildStatCard(
                  'Workouts',
                  workouts.length
                      .toString(),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: buildStatCard(
                  'Exercises',
                  getTotalExercises()
                      .toString(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: buildStatCard(
                  'Total Sets',
                  getAllTotalSets()
                      .toString(),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: buildStatCard(
                  'Strongest',
                  getStrongestLift(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStatCard(
    String title,
    String value,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color:
            Theme.of(context).cardColor,

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWorkoutList() {
    final filteredWorkouts =
        getFilteredWorkouts();

    return Padding(
      padding:
          const EdgeInsets.all(16),

      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },

            decoration: InputDecoration(
              hintText:
                  'Search workout',

              prefixIcon:
                  const Icon(Icons.search),

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child:
                filteredWorkouts.isEmpty
                    ? const Center(
                        child: Text(
                          'No workouts found',
                        ),
                      )
                    : ListView.builder(
                        itemCount:
                            filteredWorkouts
                                .length,

                        itemBuilder:
                            (
                              context,
                              filteredIndex,
                            ) {
                              final workout =
                                  filteredWorkouts[
                                      filteredIndex];

                              final realIndex =
                                  workouts
                                      .indexOf(
                                workout,
                              );

                              final exercises =
                                  workout[
                                          'exercises']
                                      as List;

                              final totalSets =
                                  getTotalSets(
                                workout,
                              );

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,

                                    MaterialPageRoute(
                                      builder:
                                          (
                                            context,
                                          ) =>
                                              WorkoutDetailsScreen(
                                        workout:
                                            workout,

                                        onWorkoutChanged:
                                            (
                                              updatedWorkout,
                                            ) {
                                          updateWorkout(
                                            realIndex,
                                            updatedWorkout,
                                          );
                                        },

                                        getExerciseHistory:
                                            (
                                              exerciseName,
                                            ) {
                                          return getExerciseHistory(
                                            exerciseName,
                                            realIndex,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },

                                child:
                                    Container(
                                  margin:
                                      const EdgeInsets.only(
                                    bottom: 16,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        Theme.of(
                                              context,
                                            )
                                            .cardColor,

                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),
                                  ),

                                  child:
                                      ListTile(
                                    contentPadding:
                                        const EdgeInsets.all(
                                      16,
                                    ),

                                    title:
                                        Text(
                                      workout[
                                          'bodyPart'],

                                      style:
                                          const TextStyle(
                                        fontSize:
                                            22,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    subtitle:
                                        Text(
                                      '${exercises.length} exercises • $totalSets sets\n${workout['date']}',
                                    ),

                                    trailing:
                                        IconButton(
                                      icon:
                                          const Icon(
                                        Icons
                                            .delete,

                                        color:
                                            Colors.red,
                                      ),

                                      onPressed:
                                          () {
                                        deleteWorkout(
                                          realIndex,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                      ),
          ),
        ],
      ),
    );
  }

  Widget buildCalendarView() {
    if (workouts.isEmpty) {
      return const Center(
        child: Text(
          'No calendar data yet',
        ),
      );
    }

    return ListView.builder(
      padding:
          const EdgeInsets.all(16),

      itemCount: workouts.length,

      itemBuilder: (context, index) {
        final workout = workouts[index];

        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.calendar_today,
            ),

            title:
                Text(workout['date']),

            subtitle:
                Text(workout['bodyPart']),
          ),
        );
      },
    );
  }

  Widget buildSettings() {
    return ListView(
      padding:
          const EdgeInsets.all(16),

      children: [
        SwitchListTile(
          title:
              const Text('Dark Mode'),

          value: widget.isDarkMode,

          onChanged: saveDarkMode,
        ),

        const Divider(),

        ListTile(
          leading:
              const Icon(Icons.notifications),

          title: const Text(
            'Workout Reminder',
          ),

          subtitle: Text(
            reminderTime == null
                ? 'No reminder set'
                : 'Reminder set at ${reminderTime!.format(context)}',
          ),

          trailing: ElevatedButton(
            onPressed: () async {
              final pickedTime =
                  await showTimePicker(
                context: context,

                initialTime:
                    reminderTime ??
                        TimeOfDay.now(),
              );

              if (pickedTime != null) {
                saveReminder(
                  pickedTime,
                );
              }
            },

            child: const Text('Set'),
          ),
        ),
      ],
    );
  }

  Widget getCurrentScreen() {
    if (selectedIndex == 0) {
      return buildDashboard();
    }

    if (selectedIndex == 1) {
      return buildWorkoutList();
    }

    if (selectedIndex == 2) {
      return buildCalendarView();
    }

    return buildSettings();
  }

  String getTitle() {
    if (selectedIndex == 0) {
      return 'Dashboard';
    }

    if (selectedIndex == 1) {
      return 'Workout History';
    }

    if (selectedIndex == 2) {
      return 'Calendar';
    }

    return 'Settings';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTitle(),

          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        backgroundColor:
            Colors.deepPurple,

        foregroundColor:
            Colors.white,
      ),

      body: getCurrentScreen(),

      bottomNavigationBar:
          NavigationBar(
        selectedIndex: selectedIndex,

        onDestinationSelected:
            (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),

          NavigationDestination(
            icon:
                Icon(Icons.fitness_center),
            label: 'Workouts',
          ),

          NavigationDestination(
            icon:
                Icon(Icons.calendar_month),
            label: 'Calendar',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),

      floatingActionButton:
          selectedIndex == 0 ||
                  selectedIndex == 1
              ? FloatingActionButton(
                  backgroundColor:
                      Colors.deepPurple,

                  foregroundColor:
                      Colors.white,

                  onPressed: () async {
                    final result =
                        await Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder:
                            (
                              context,
                            ) =>
                                const AddWorkoutScreen(),
                      ),
                    );

                    if (result != null) {
                      addWorkout(
                        Map<String,
                            dynamic>.from(
                          result,
                        ),
                      );
                    }
                  },

                  child:
                      const Icon(Icons.add),
                )
              : null,
    );
  }
}
