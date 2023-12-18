import 'package:signal_todos/data/database/database.dart';

final todoRepo = TodoRepo();

class TodoRepo {
  final AppDatabase _db = AppDatabase();

  Stream<List<TodoItem>> watchAllTodoItems() =>
      _db.select(_db.todoItems).watch().map((event) {
        return event.reversed.toList();
      });

  Future<void> insertTodoItem(TodoItemsCompanion todoItem) =>
      _db.into(_db.todoItems).insert(todoItem);

  Future<void> updateTodoItem(TodoItem todoItem) =>
      _db.update(_db.todoItems).replace(todoItem);

  Future<void> deleteTodoItem(TodoItem todoItem) =>
      _db.delete(_db.todoItems).delete(todoItem);
}
