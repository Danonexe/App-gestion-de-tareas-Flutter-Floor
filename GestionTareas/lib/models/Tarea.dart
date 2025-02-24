import 'package:floor/floor.dart';

@entity
class Task {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  String description;
  bool isCompleted;

  Task({
    this.id,
    required this.description,
    this.isCompleted = false,
  });
}