import 'package:flutter/material.dart';
import 'package:signal_todos/data/database/database.dart';
import 'package:signal_todos/data/repos/todo_repo.dart';
import 'package:signals/signals_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signal Notes',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        cardColor: Colors.grey[900],
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.grey,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.grey,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final todoController = TextEditingController();
  final todosSignal = todoRepo.watchAllTodoItems().toSignal();

  @override
  void dispose() {
    todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todosState = todosSignal.watch(context);

    if (todosState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final todos = todosState.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signal Notes'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: todoController,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              value = value.trim();
              if (value.isEmpty) return;

              todoRepo.insertTodoItem(TodoItemsCompanion.insert(title: value));
              todoController.clear();
            },
            decoration: const InputDecoration(
              labelText: 'New Todo...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
            child: todos.isEmpty
                ? const Center(
                    child: Text('No Todos'),
                  )
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          onTap: () {
                            todoRepo.updateTodoItem(
                              todo.copyWith(isDone: !todo.isDone),
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              todoRepo.deleteTodoItem(todo);
                            },
                          ),
                          leading: Checkbox(
                            value: todo.isDone,
                            onChanged: (value) {
                              todoRepo.updateTodoItem(
                                todo.copyWith(isDone: value),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  )),
      ]),
    );
  }
}
