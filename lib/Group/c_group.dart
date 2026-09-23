import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Group/Model/m_group.dart';
import 'package:tasknote/Service/s_isar.dart';

class GroupNotesController {
  final IsarService isarService = IsarService();

  late final Isar isar;

  Future<void> init() async {
    isar = await isarService.db;
  }

  // ----------------------------
  // ISAR DATABASE FUNCTIONS
  // ----------------------------

  // Insert (Checks Duplicate based on gName)
  Future<bool> checkAndAddGroup({
    required Group group,
    BuildContext? context,
  }) async {
    // Checks if group with same gname exists.
    if (await groupExists(group.gName)) {
      // ONLY show UI messages if context is provided and currently mounted
      if (context != null && context.mounted) {
        scaffoldMessenger("A folder with this name already exists!");
      }

      return false; // Not added
    }

    await isar.writeTxn(() async {
      // Prevent duplicate group
      final existing = await isar.groups
          .where()
          .uidEqualTo(group.uid)
          .findFirst();

      if (existing != null) {
        group.id = existing.id; // keep local Isar id
      }

      await isar.groups.put(group);
    });

    logger.d("${group.gName} group added");
    return true; // Added
  }

  // Update (Checks Duplicate based on gName)
  Future<bool> checkAndUpdateGroup({
    required Group oldGroup, // existing (from DB)
    required Group newGroup, // new data (from UI)
    BuildContext? context,
  }) async {
    // 1. Check if the name has actually changed
    if (oldGroup.gName != newGroup.gName) {
      // 2. Checks if group with same gname exists.
      if (await groupExists(newGroup.gName)) {
        // ONLY show UI messages if context is provided and currently mounted
        if (context != null && context.mounted) {
          scaffoldMessenger("A folder with this name already exists!");
        }

        return false; // Not added
      }
    }

    // 3. Update
    await isar.writeTxn(() async {
      // Assign new values
      oldGroup.gName = newGroup.gName;
      oldGroup.description = newGroup.description;
      oldGroup.createdAt = newGroup.createdAt;
      oldGroup.updatedAt = newGroup.updatedAt;
      oldGroup.decorColor = newGroup.decorColor;
      oldGroup.noteCount = newGroup.noteCount;
      oldGroup.notesUidsList = newGroup.notesUidsList;

      await isar.groups.put(oldGroup);
    });

    logger.d("Group having id: ${oldGroup.id} updated");
    return true; // Updated
  }

  // Update noteCount & notesUidsList
  Future<void> updateGroupNoteInfo(Group updatedGroup) async {
    await isar.writeTxn(() async {
      await isar.groups.put(updatedGroup);
    });
  }

  // Delete
  Future<void> deleteGroup(int id) async {
    await isar.writeTxn(() async {
      await isar.groups.delete(id);
    });
    logger.d("Group having id: $id deleted");
  }

  // Multiple group select and delete
  Future<void> deleteMultipleGroups({required List<String> uidlist}) async {
    await isar.writeTxn(() async {
      for (var uid in uidlist) {
        await isar.groups.deleteByUid(uid);
        logger.d("Deleted group uid $uid");
      }
    });
  }

  // Get group based on id
  Future<Group?> getGroupById(int id) async {
    return await isar.groups.get(id);
  }

  // Get group based on uid
  Future<Group?> getGroupByUid(String uid) async {
    return await isar.groups.getByUid(uid);
  }

  // Get total no. of groups
  Future<int> getTotalGroupCount() async {
    return isar.groups.count();
  }

  // Check if group exists
  Future<bool> groupExists(String gName) async {
    // .findFirst() is faster than .findAll() for existence checks
    final group = await isar.groups.filter().gNameEqualTo(gName).findFirst();

    return group != null;
  }

  // Return current list of groups
  Future<List<Group>> getAllGroups() async {
    return isar.groups.where().sortByGName().findAll();
  }

  // ----------------------------
  // STREAM FUNCTIONS
  // ----------------------------

  Stream<List<Group>> listenToGroupSchema() {
    return isar.groups.where().watch(fireImmediately: true);
  }

  // ----------------------------
  // UTILITY FUNCTIONS
  // ----------------------------

  // Sort Groups (Multiple time sort)
  List<Group> sortGroups(String sort, List<Group> originalList) {
    // Create a copy so the original list is not modified
    final list = List<Group>.from(originalList);

    switch (sort) {
      case "Created":
        // Newest first
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case "Last updated":
        // Most recently updated first
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;

      case "Alphabetically":
        // Sort by name A → Z (case-sensitive)
        list.sort((a, b) => a.gName.compareTo(b.gName));
        break;

      default:
        // No sorting
        break;
    }

    return list;
  }
}
