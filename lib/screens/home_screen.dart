import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo_project/constants/colors.dart';
import 'package:todo_project/model/todo_model.dart';
import 'package:todo_project/provider/todo_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    final text = _taskController.text;
    if (text.trim().isEmpty) {
      CherryToast.warning(
        toastDuration: const Duration(seconds: 2),
        animationDuration: const Duration(seconds: 2),
        title: const Text('Please enter a task'),
        animationType: AnimationType.fromTop,
      ).show(context);
      return;
    }
    ref.read(todoProvider.notifier).addTodo(text);
    _taskController.clear();
    CherryToast.success(
      toastDuration: const Duration(seconds: 2),
      animationDuration: const Duration(seconds: 2),
      title: const Text('Task added!'),
      animationType: AnimationType.fromTop,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 80),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: FaIcon(
                          size: 22,
                          FontAwesomeIcons.listCheck,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Tasks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        // Only this Consumer rebuilds when remaining count changes
                        Consumer(
                          builder: (context, ref, _) {
                            final remaining =
                                ref.watch(remainingCountProvider);
                            return Text(
                              '$remaining Remaining',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.completedTaskColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                cursorColor: Colors.black,
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search tasks..',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.completedTaskColor,
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _taskController,
                      onSubmitted: (_) => _addTask(),
                      decoration: InputDecoration(
                        hintText: 'Add a new task...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.completedTaskColor,
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: _addTask,
                  borderRadius: BorderRadius.circular(10),
                  splashColor: AppColors.backgroundColor,
                  highlightColor: AppColors.backgroundColor,
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(5),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                dividerHeight: 0,
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                controller: _tabController,
                tabs: const [
                  Tab(child: Text('All')),
                  Tab(child: Text('Active')),
                  Tab(child: Text('Done')),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TodoListView(provider: filteredTodosProvider),
                  _TodoListView(provider: activeTodosProvider),
                  _TodoListView(provider: doneTodosProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoListView extends ConsumerWidget {
  final Provider<List<TodoModel>> provider;

  const _TodoListView({required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(provider);

    if (todos.isEmpty) {
      return const Center(
        child: Text(
          'No tasks found',
          style: TextStyle(color: AppColors.completedTaskColor, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Dismissible(
          key: ValueKey(todo.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            ref.read(todoProvider.notifier).deleteTodo(todo.id);
            CherryToast.error(
              animationDuration: const Duration(seconds: 2),
              toastDuration: const Duration(seconds: 2),
              title: const Text('Task deleted'),
              animationType: AnimationType.fromTop,
            ).show(context);
          },
          background: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Container(
            height: 60,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Checkbox(
                  checkColor: Colors.white,
                  activeColor: AppColors.primaryColor,
                  shape: const CircleBorder(),
                  value: todo.isCompleted,
                  onChanged: (_) {
                    ref.read(todoProvider.notifier).toggleTodo(todo.id);
                  },
                ),
                Expanded(
                  child: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: todo.isCompleted
                          ? AppColors.completedTaskColor
                          : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
