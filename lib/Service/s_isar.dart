import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/Group/Model/m_group.dart';
import 'package:tasknote/Reminder/Model/m_reminder.dart';
import 'package:tasknote/User/Model/m_user.dart';

class IsarService {
  // Create a single, static internal instance of the class
  static final IsarService _instance = IsarService._internal();

  // A factory constructor that always returns the exact same instance
  factory IsarService() {
    return _instance;
  }

  // A private named constructor used only inside this class
  IsarService._internal();

  // The private variable to cache the future
  Future<Isar>? _dbFuture;

  // The getter to safely access the DB future without race conditions
  Future<Isar> get db {
    _dbFuture ??= _openDB();
    return _dbFuture!;
  }

  Future<Isar> _openDB() async {
    // Check if an instance is already active
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();

      return await Isar.open(
        [NoteSchema, GroupSchema, MUserSchema, ReminderSchema],
        directory: dir.path,
        inspector: true,
      );
    }

    // Safely return the existing active instance
    return Isar.getInstance()!;
  }
}
