import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signal Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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

final todos = <Todo>[].toSignal();
final notDoneTodos =
    computed(() => todos().where((todo) => !todo.isDone).toList());

class _HomeScreenState extends State<HomeScreen> {
  final todoController = TextEditingController();

  @override
  void dispose() {
    todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doneTodoList = notDoneTodos.watch(context);
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

              todos.add(
                Todo.newTodo(value),
              );
              todoController.clear();
            },
            decoration: const InputDecoration(
              labelText: 'Note',
            ),
          ),
        ),
        Expanded(
            child: ListView.builder(
          itemCount: doneTodoList.length,
          itemBuilder: (context, index) {
            final todo = doneTodoList[index];
            return ListTile(
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: Checkbox(
                value: todo.isDone,
                onChanged: (value) {
                  todos[index] = todos[index].copyWith(
                    isDone: value!,
                  );
                },
              ),
            );
          },
        )),
      ]),
    );
  }
}

class Todo extends Equatable {
  final String title;
  final bool isDone;

  const Todo({
    required this.title,
    this.isDone = false,
  });

  static Todo newTodo(String title) => Todo(
        title: title,
      );

  Todo copyWith({
    String? title,
    bool? isDone,
  }) {
    return Todo(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  List<Object?> get props => [title, isDone];
}
