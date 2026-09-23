import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:tasknote/User/Model/m_user.dart';
import 'package:tasknote/Service/s_isar.dart';

class UserController {
  final IsarService isarService = IsarService();
  final Logger logger = Logger();

  late final Isar isar;

  Future<void> init() async {
    isar = await isarService.db;
  }

  /// CREATE: Adds a new user to the local database
  Future<Id> add(MUser user) async {
    return await isar.writeTxn(() async {
      return await isar.mUsers.put(user);
    });
  }

  /// UPDATE: Updates an existing user record
  /// Isar's .put() automatically handles updates if the user.id matches an existing record
  Future<Id> update(MUser user) async {
    return await isar.writeTxn(() async {
      return await isar.mUsers.put(user);
    });
  }

  /// DELETE: Removes a user from the database using their Isar Id
  Future<bool> delete(Id id) async {
    return await isar.writeTxn(() async {
      return await isar.mUsers.delete(id);
    });
  }

  /// FETCH: Retrieves a user by their local Isar Id
  Future<MUser?> fetchById(Id id) async {
    return await isar.mUsers.get(id);
  }

  /// FETCH: Retrieves a user by their unique Firebase UID string
  /// (Requires running build_runner first to use the generated query filters)
  Future<MUser?> fetchByUid(String uid) async {
    return await isar.mUsers.filter().uidEqualTo(uid).findFirst();
  }

  /// FETCH ALL: Retrieves all local user records
  Future<List<MUser>> fetchAll() async {
    return await isar.mUsers.where().findAll();
  }
}
