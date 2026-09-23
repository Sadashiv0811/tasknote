import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tasknote/Note/common.dart';
import 'package:tasknote/Service/s_notification.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Other/routes.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/Group/Model/m_group.dart';
import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/Service/s_shared_pref.dart';
import 'package:tasknote/Group/Views/ae_group.dart';
import 'package:tasknote/Note/Views/v_note_types.dart';
import 'package:tasknote/Other_Views/v_splash.dart';

class VGroups extends StatefulWidget {
  const VGroups({super.key});

  @override
  State<VGroups> createState() => _VGroupsState();
}

class _VGroupsState extends State<VGroups> {
  late Stream<List<Group>> _groupStream;
  late Stream<List<Note>> _notesStream;

  final TextEditingController searchController = TextEditingController();
  final NotificationService notificationService = NotificationService();

  String sort = "Created";
  String searchQuery = "";

  final Set<String> _selectedGroupUids = {};

  // Helper getter to check if selection mode is active
  bool get _isSelectionMode => _selectedGroupUids.isNotEmpty;

  @override
  void initState() {
    super.initState();

    _groupStream = groupController.listenToGroupSchema();
    _notesStream = noteController.listenToGroupedNoteSchema();
    _initialize();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<Group>>(
        stream: _groupStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Folders not added yet.\nTap '+' to create one.",
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          List<Group> originalGroupList = snapshot.data!;

          List<Group> sortedGroupList = groupController.sortGroups(
            sort,
            originalGroupList,
          );

          // Filter the list based on search query before rendering
          if (searchQuery.isNotEmpty) {
            sortedGroupList = sortedGroupList.where((group) {
              final gNameLower = group.gName.toLowerCase();
              final searchLower = searchQuery.toLowerCase();
              return gNameLower.contains(searchLower);
            }).toList();
          }

          return Column(
            children: [
              if (_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedGroupUids.clear();
                          });
                        },
                      ),

                      SelectedCount(
                        text:
                            "${_selectedGroupUids.length}/${sortedGroupList.length}",
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteFolders(context),
                      ),
                    ],
                  ),
                )
              else
                // Searchbar
                CSearchbar(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  hintText: "Search folders...",
                  searchQuery: searchQuery,
                  clearSearch: () {
                    searchController.clear();
                    setState(() {
                      searchQuery = "";
                    });
                  },
                ),

              // Sort button
              Visibility(
                visible: sortedGroupList.isNotEmpty && !_isSelectionMode,
                child: CActionContainer(
                  showViewButton: false,
                  sort: sort,
                  onTapSort: () async {
                    final result = await showModalBottomSheet<String>(
                      backgroundColor: Colors.transparent,
                      useSafeArea: true,
                      sheetAnimationStyle: AppTheme.animationStyle(),
                      shape: AppTheme.roundedRectangleBorder(),
                      context: context,
                      builder: (context) => SortViewOptions(
                        title: 'Sort By',
                        options: sortOptions,
                        showIcons: false,
                        currentSelected: sort,
                      ),
                    );

                    if (result != null && result.isNotEmpty) {
                      await SharedPrefService.saveGroupSortType(result);
                      if (result != sort) {
                        setState(() {
                          sort = result;
                        });
                        logger.d(sort);
                      }
                    }
                  },
                ),
              ),

              // Empty list when searching
              if (sortedGroupList.isEmpty && searchQuery.isNotEmpty)
                EmptySearchResult(
                  text: "No folders found matching\n\"$searchQuery\"",
                ),

              StreamBuilder<List<Note>>(
                stream: _notesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Grab notes from stream data or default to an empty list
                  final allGroupedNotes = snapshot.data ?? [];

                  return Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: getWidth(context, 0.04),
                        vertical: getWidth(context, 0.02),
                      ),
                      itemCount: sortedGroupList.length,
                      itemBuilder: (context, index) {
                        final group = sortedGroupList[index];
                        final isSelected = _selectedGroupUids.contains(
                          group.uid,
                        );

                        // Filter notes that belong to this specific group
                        final groupNotes = allGroupedNotes
                            .where(
                              (note) =>
                                  group.notesUidsList?.contains(note.uid) ??
                                  false,
                            )
                            .toList();

                        // Reusable item widget
                        return _GroupTileItem(
                          group: group,
                          notesInsideGroup: groupNotes,
                          notificationService: notificationService,
                          isSelected: isSelected,
                          isSelectionMode: _isSelectionMode,

                          onLongPress: () {
                            setState(() {
                              _selectedGroupUids.add(group.uid);
                            });
                          },

                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedGroupUids.remove(group.uid);
                              } else {
                                _selectedGroupUids.add(group.uid);
                              }
                            });
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  Routes.addEditGroup,
                  arguments: AddEditGroupArgs(
                    edit: false,
                    selectedNoteUidList: [],
                  ),
                );
              },
              child: const Icon(Icons.folder),
            ),
    );
  }

  Future<void> _initialize() async {
    final savedSort = await SharedPrefService.getGroupSortType();

    if (mounted && savedSort.isNotEmpty) {
      setState(() => sort = savedSort);
    }
  }

  Future<void> _confirmDeleteFolders(BuildContext context) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Folders"),
            content: Text(
              "Are you sure you want to delete ${_selectedGroupUids.length} folder(s)? This action cannot be undone.\nAll notes inside these folder(s) will also be deleted.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Delete"),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed != true) return;

    final selectedUids = List<String>.from(_selectedGroupUids);

    final groups = await Future.wait(
      selectedUids.map(groupController.getGroupByUid),
    );

    final noteUids = groups
        .whereType<Group>()
        .expand((group) => group.notesUidsList ?? <String>[])
        .toSet()
        .toList();

    if (noteUids.isNotEmpty) {
      await reminderController.cancelReminders(uidList: noteUids);
      await noteController.deleteMultipleNotes(uidlist: noteUids);
    }

    await groupController.deleteMultipleGroups(uidlist: selectedUids);

    // Protect against Async Gap state issues
    if (!mounted) return;
    setState(() {
      _selectedGroupUids.clear();
    });
  }
}

class _GroupTileItem extends StatefulWidget {
  final Group group;
  final List<Note> notesInsideGroup;
  final NotificationService notificationService;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _GroupTileItem({
    required this.group,
    required this.notesInsideGroup,
    required this.notificationService,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_GroupTileItem> createState() => _GroupTileItemState();
}

class _GroupTileItemState extends State<_GroupTileItem> {
  // Local state for reminders
  List<String> _notesWithReminders = [];

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  // Catches updates when the parent stream emits new notes
  @override
  void didUpdateWidget(covariant _GroupTileItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_notesChanged(oldWidget)) {
      _fetchReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color groupDecorColor = widget.group.color;

    final int protectedNoteCount =
        widget.group.noteCount - widget.notesInsideGroup.length;

    // Build core tile layout card
    Widget tileCard = Card(
      elevation: widget.isSelected ? 8.0 : 3.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: widget.isSelected
              ? (isDark ? AppColors.lFirstColor : AppColors.dThirdColor)
              : groupDecorColor.withValues(alpha: 0.3),
          width: widget.isSelected ? 2.5 : 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          // Subtle linear gradient tint running under the folder background layer
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                groupDecorColor.withValues(alpha: 0.05),
                theme.cardTheme.color ??
                    (isDark ? AppColors.dThirdColor : Colors.white),
              ],
            ),
          ),
          child: ExpansionTile(
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            splashColor: groupDecorColor.withValues(alpha: 0.15),
            childrenPadding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
            // Clears default rigid divider lines built into standard ExpansionTiles
            shape: const Border(),
            collapsedShape: const Border(),
            iconColor: groupDecorColor,
            collapsedIconColor: isDark ? Colors.white60 : Colors.black54,
            leading: CircleAvatar(
              backgroundColor: groupDecorColor.withValues(alpha: 0.15),
              child: Icon(Icons.folder_copy_rounded, color: groupDecorColor),
            ),
            title: Text(
              widget.group.gName,
              style: theme.textTheme.bodyMedium!.copyWith(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Notes: ${widget.group.noteCount}",
              style: theme.textTheme.bodySmall!.copyWith(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            children: [
              if (widget.group.description != null &&
                  widget.group.description!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 4.0,
                  ),
                  child: Text(
                    "Description: ${widget.group.description}",
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              _GroupActionBar(
                onTapAddNote: () async {
                  final noteType = await showNoteTypeDialog(context);

                  if (!context.mounted || noteType == null) return;

                  // Open text note screen or checklist screen based on noteType
                  await Navigator.pushNamed(
                    context,
                    noteType == NoteType.text
                        ? Routes.addEditNote
                        : Routes.addEditCheckListNote,
                    arguments: AddEditNoteArgs(
                      edit: false,
                      groupNote: true,
                      groupId: widget.group.id,
                    ),
                  );

                  if (mounted) {
                    _fetchReminders();
                  }
                },
                onTapEditGroup: () async {
                  await Navigator.pushNamed(
                    context,
                    Routes.addEditGroup,
                    arguments: AddEditGroupArgs(
                      edit: true,
                      eGroup: widget.group,
                    ),
                  );
                },
                onTapDeleteGroup: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => DeleteConfirmation(
                      singleDeletion: true,
                      item: "folder",
                      nCount: widget.group.noteCount,
                      yesAction: () async => cleanUp(widget.group),
                    ),
                  );
                },
                onTapUngroup: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => _RemoveConfirmation(
                      yesAction: () async {
                        await noteController.unGroupNotes(
                          uidList: widget.group.notesUidsList!,
                          gName: widget.group.gName,
                        );
                        await groupController.deleteGroup(widget.group.id);
                      },
                    ),
                  );
                },
                emptyGroup: widget.notesInsideGroup.isEmpty,
              ),

              const SizedBox(height: 8),

              if (protectedNoteCount > 0) ...[
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.015),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock),
                        SizedBox(width: 20),
                        Text(
                          "$protectedNoteCount password protected note${protectedNoteCount != 1 ? "s." : "."}",
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              if (widget.notesInsideGroup.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.notesInsideGroup.length,
                  itemBuilder: (context, index) {
                    final note = widget.notesInsideGroup[index];
                    final hasReminder = _notesWithReminders.contains(note.uid);
                    return _buildSlidableNoteItem(
                      context,
                      note,
                      hasReminder,
                      isDark,
                      theme,
                    );
                  },
                )
              else
                _buildEmptyFolderPlaceholder(
                  context,
                  theme,
                  protectedNoteCount,
                ),
            ],
          ),
        ),
      ),
    );

    // Wrap layout to intercept touch mechanics depending on selection state
    return Container(
      margin: EdgeInsets.only(top: getWidth(context, 0.04)),
      child: widget.isSelectionMode
          ? GestureDetector(
              onTap: widget.onTap,
              child: AbsorbPointer(
                absorbing:
                    true, // Disables internal ExpansionTile taps completely
                child: tileCard,
              ),
            )
          : GestureDetector(onLongPress: widget.onLongPress, child: tileCard),
    );
  }

  // Extracted Slidable Note Item
  Widget _buildSlidableNoteItem(
    BuildContext context,
    Note note,
    bool hasReminder,
    bool isDark,
    ThemeData theme,
  ) {
    final Color noteDecorColor = note.color;

    return Slidable(
      key: Key(note.uid.toString()),

      startActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              await showDialog(
                context: context,
                builder: (context) => _RemoveConfirmation(
                  delete: false,
                  yesAction: () async {
                    await noteController.unGroupNotes(
                      uidList: [note.uid.toString()],
                      gName: widget.group.gName,
                    );
                    await noteController.removeNoteFromGroup(
                      groupId: widget.group.id,
                      noteUid: note.uid.toString(),
                    );
                  },
                ),
              );
            },
            backgroundColor: AppColors.error.withValues(alpha: 0.9),
            foregroundColor: Colors.white,
            icon: Icons.layers_clear_rounded,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
          ),
        ],
      ),

      endActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              await showDialog(
                context: context,
                builder: (context) => DeleteConfirmation(
                  singleDeletion: true,
                  yesAction: () async {
                    await noteController.removeNoteFromGroup(
                      groupId: widget.group.id,
                      noteUid: note.uid.toString(),
                    );

                    // Cancel Reminder
                    await reminderController.cancelReminders(note: note);

                    // Delete reminder object
                    await reminderController.deleteReminderByNoteUID(note.uid);

                    // Delete note object
                    await noteController.deleteNote(note.id);
                  },
                ),
              );
            },
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_forever_rounded,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(12),
            ),
          ),
        ],
      ),

      child: Container(
        width: getWidth(context, 1),
        height: getHeight(context, 0.085),
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: noteDecorColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            // Open text note screen or checklist screen based on noteType
            await Navigator.pushNamed(
              context,
              note.isCheckList
                  ? Routes.addEditCheckListNote
                  : Routes.addEditNote,
              arguments: AddEditNoteArgs(
                edit: true,
                eNote: note,
                groupId: widget.group.id,
                groupNote: true,
              ),
            );

            // Refresh instantly after editing or removing a reminder!
            _fetchReminders();
          },
          child: Row(
            children: [
              Container(
                width: 5,
                height: double.infinity,
                color: noteDecorColor,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisAlignment: .center,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _NoteTitle(title: note.title)),
                          if (hasReminder) ...[
                            const SizedBox(width: 6),
                            _CReminderIcon(), // Keeps layout balanced and uniform
                          ],
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 3.0),
                      DisplayContent(note: note, isVertical: false),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Extracted Empty State View
  Widget _buildEmptyFolderPlaceholder(
    BuildContext context,
    ThemeData theme,
    int protectedNoteCount,
  ) {
    return protectedNoteCount == 0
        ? Container(
            height: getHeight(context, 0.1),
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                "Empty folder\nClick on Add Note to add one.",
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          )
        : SizedBox.shrink();
  }

  bool _notesChanged(_GroupTileItem oldWidget) {
    return !const ListEquality<String>().equals(
      oldWidget.notesInsideGroup.map((e) => e.uid).toList(),
      widget.notesInsideGroup.map((e) => e.uid).toList(),
    );
  }

  // The local fetcher method
  Future<void> _fetchReminders() async {
    final uidList = widget.notesInsideGroup.map((note) => note.uid).toList();

    if (uidList.isEmpty) {
      if (mounted) setState(() => _notesWithReminders = []);
      return;
    }

    final reminders = await widget.notificationService.getNotesWithReminders(
      uidList,
    );

    if (mounted) {
      setState(() {
        _notesWithReminders = reminders;
      });
    }
  }

  void cleanUp(Group group) async {
    final noteUids = group.notesUidsList ?? [];

    if (noteUids.isNotEmpty) {
      // Cancel reminder
      await reminderController.cancelReminders(uidList: noteUids);
      // Delete notes inside group
      await noteController.deleteMultipleNotes(uidlist: noteUids);
    }
    // Delete group
    await groupController.deleteGroup(group.id);
  }
}

// Stateless Widgets
class _GroupActionBar extends StatelessWidget {
  final VoidCallback onTapAddNote;
  final VoidCallback onTapEditGroup;
  final VoidCallback onTapDeleteGroup;
  final VoidCallback onTapUngroup;
  final bool emptyGroup;

  const _GroupActionBar({
    required this.onTapAddNote,
    required this.onTapEditGroup,
    required this.onTapDeleteGroup,
    required this.onTapUngroup,
    required this.emptyGroup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.015),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // Add note inside existing group
          TextButton.icon(
            onPressed: onTapAddNote,
            label: const Text("Add Note", style: TextStyle(fontSize: 14)),
            icon: const Icon(Icons.add_rounded, size: 18),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),

          const Spacer(),

          // Edit group info
          IconButton(
            onPressed: onTapEditGroup,
            icon: const Icon(Icons.mode_edit_outline_rounded, size: 20),
            tooltip: "Edit Folder",
          ),

          // Delete group
          IconButton(
            onPressed: onTapDeleteGroup,
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: Colors.red,
            tooltip: "Delete Folder",
          ),

          if (emptyGroup == false)
            // Remove all notes from group
            IconButton(
              onPressed: onTapUngroup,
              icon: const Icon(Icons.folder_off_outlined, size: 20),
              tooltip: "Un-group Notes",
            ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _RemoveConfirmation extends StatelessWidget {
  final VoidCallback yesAction;
  final bool? delete;
  const _RemoveConfirmation({required this.yesAction, this.delete = true});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Remove"),
      content: delete!
          ? Text(
              "Are you sure you want to remove all notes out of this folder?\nThe folder will be deleted",
              textAlign: TextAlign.start,
            )
          : Text("Are you sure you want to remove this note from folder?"),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                yesAction();
              },
              child: Text("Yes"),
            ),
          ],
        ),
      ],
    );
  }
}

class _CReminderIcon extends StatelessWidget {
  const _CReminderIcon();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.primary : AppColors.dSecondColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: Icon(Icons.alarm, size: 15, color: Colors.white)),
      ),
    );
  }
}

class _NoteTitle extends StatelessWidget {
  final String title;
  const _NoteTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
