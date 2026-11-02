
import 'package:flutter/material.dart';
import 'add_task_screen.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color navy = Color.fromARGB(255, 17, 26, 42);
  static const Color cardColor = Color(0xFF1C2738);
  static const Color softBlue = Color(0xFF8AB4F8);

  final List<Map<String, dynamic>> _tasks = [];

  // Search controller and query.
  final TextEditingController _searchController =
      TextEditingController();
  String _searchQuery = '';

  int get _completedCount =>
      _tasks.where((task) => task['isCompleted'] == true).length;

  int get _pendingCount => _tasks.length - _completedCount;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final savedTasks = await StorageService.loadTasks();

    if (!mounted) return;

    setState(() {
      _tasks.addAll(savedTasks);
    });
  }

  Future<void> _addTask() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );

    if (result != null && mounted) {
      result['isCompleted'] = false;

      setState(() {
        _tasks.add(result);
      });

      await StorageService.saveTasks(_tasks);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task added successfully!'),
        ),
      );
    }
  }

  // Edit an existing task.
  Future<void> _editTask(int index) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          task: Map<String, dynamic>.from(_tasks[index]),
        ),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _tasks[index] = {
        ...result,
        'isCompleted': _tasks[index]['isCompleted'] == true,
      };
    });

    await StorageService.saveTasks(_tasks);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task updated successfully!'),
      ),
    );
  }

  Future<void> _toggleTask(int index) async {
    setState(() {
      _tasks[index]['isCompleted'] =
          !(_tasks[index]['isCompleted'] == true);
    });

    await StorageService.saveTasks(_tasks);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _tasks[index]['isCompleted'] == true
              ? 'Task completed!'
              : 'Task marked as pending!',
        ),
      ),
    );
  }

  Future<void> _deleteTask(int index) async {
    final deletedTask = _tasks[index];

    setState(() {
      _tasks.removeAt(index);
    });

    await StorageService.saveTasks(_tasks);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deletedTask['title']} deleted!'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () async {
            setState(() {
              _tasks.insert(
                index.clamp(0, _tasks.length),
                deletedTask,
              );
            });

            await StorageService.saveTasks(_tasks);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter tasks by title or description.
    final filteredTasks = _tasks.asMap().entries.where((entry) {
      final task = entry.value;
      final title =
          (task['title'] as String? ?? '').toLowerCase();
      final description =
          (task['description'] as String? ?? '').toLowerCase();

      return title.contains(_searchQuery) ||
          description.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good day 👋',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'My Tasks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: cardColor,
                    radius: 25,
                    child: Icon(
                      Icons.person_outline,
                      color: softBlue,
                      size: 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Functional search bar.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    icon: const Icon(
                      Icons.search,
                      color: softBlue,
                    ),
                    hintText: 'Search your tasks...',
                    hintStyle:
                        const TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Your Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.check_circle_outline,
                      title: 'Completed',
                      count: '$_completedCount',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.pending_actions,
                      title: 'Pending',
                      count: '$_pendingCount',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Tasks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.calendar_month, color: softBlue),
                ],
              ),

              const SizedBox(height: 15),

              if (_tasks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 55,
                        color: softBlue,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No tasks yet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Add your first task to get started!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else if (filteredTasks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 45,
                        color: softBlue,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No matching tasks found',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Try another title or keyword.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filteredTasks.map((entry) {
                  // Keep the original task index for edit/delete actions.
                  final index = entry.key;
                  final task = entry.value;

                  final date = task['date'] as DateTime?;
                  final description =
                      (task['description'] as String?) ?? '';
                  final isCompleted =
                      task['isCompleted'] == true;

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => _toggleTask(index),
                          tooltip: isCompleted
                              ? 'Mark as pending'
                              : 'Mark as completed',
                          icon: Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isCompleted
                                ? Colors.greenAccent
                                : softBlue,
                            size: 25,
                          ),
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                task['title'] as String,
                                style: TextStyle(
                                  color: isCompleted
                                      ? Colors.white54
                                      : Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor: Colors.white54,
                                ),
                              ),

                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],

                              if (date != null) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month,
                                      color: softBlue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${date.day}/${date.month}/${date.year}',
                                      style: const TextStyle(
                                        color: softBlue,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Edit task button.
                        IconButton(
                          onPressed: () => _editTask(index),
                          tooltip: 'Edit task',
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: softBlue,
                          ),
                        ),

                        // Delete task button.
                        IconButton(
                          onPressed: () => _deleteTask(index),
                          tooltip: 'Delete task',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add New Task',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: softBlue,
                    foregroundColor: navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String count,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: softBlue, size: 28),
          const SizedBox(height: 15),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
