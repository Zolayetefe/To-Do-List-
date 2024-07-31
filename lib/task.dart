
import 'package:hive/hive.dart';
part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject{
  @HiveField(0)
  String name;
  @HiveField(1)
  DateTime date;

  Task({required this.name,required this.date});
}