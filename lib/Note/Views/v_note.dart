import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:tasknote/Share/v_share.dart';
import 'package:tasknote/Other_Views/v_splash.dart';
import 'package:tasknote/Reminder/v_reminder.dart';

class VNote extends StatefulWidget {
  const VNote({super.key});

  @override
  State<VNote> createState() => _VNoteState();
}

class _VNoteState extends State<VNote> {
  late Stream<List<Note>> _notesStream;
  Set<String> _activeReminderUids = {};

  String _lastLoadedUids = "";

  int gridCount = 2; // 2 - Large Grid, 3 - Small Grid
  String view = "Large Grid";
  String sort = "Created";
  bool sSortView = true;
  String searchQuery = "";

  List<String> selectedNoteUidList = [];
  final TextEditingController searchController = TextEditingController();
  final NotificationService notificationService = NotificationService();

  // Timer for debouncing search
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _notesStream = noteController.listenToNoteSchema(sort);
    initializeViewType();
    initializeSortType();
    _loadReminders();
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel(); // Cancel timer on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: StreamBuilder<List<Note>>(
          stream: _notesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "Notes not added yet.\nTap '+' to create one.",
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }

            List<Note> normalNotesList = snapshot.data!;

            String currentUidsString = normalNotesList
                .map((n) => n.uid)
                .join(',');
            if (_lastLoadedUids != currentUidsString) {
              _lastLoadedUids = currentUidsString;

              // Safely trigger the async reminder fetch after the build phase completes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadReminders();
              });
            }

            // Filter the list based on search query
            List<Note> filteredNotes = normalNotesList;

            if (searchQuery.isNotEmpty) {
              final searchLower = searchQuery.toLowerCase();
              filteredNotes = normalNotesList.where((note) {
                return note.title.toLowerCase().contains(searchLower);
              }).toList();
            }

            return Stack(
              children: [
                Column(
                  children: [
                    // Searchbar
                    Visibility(
                      visible: sSortView,
                      child: CSearchbar(
                        controller: searchController,
                        onChanged: _onSearchChanged, 
                        hintText: "Search notes...",
                        searchQuery: searchQuery,
                        clearSearch: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = "";
                          });
                        },
                      ),
                    ),

                    // Selected note count
                    Visibility(
                      visible: !sSortView,
                      child: SelectedCount(
                        text:
                            "${selectedNoteUidList.length} / ${filteredNotes.length}",
                      ),
                    ),

                    // Sort and View button
                    Visibility(
                      visible: sSortView && normalNotesList.isNotEmpty,
                      child: CActionContainer(
                        onTapSort: () async {
                          showSortBottomSheet();
                        },
                        onTapView: () async {
                          showViewBottomSheet();
                        },
                      ),
                    ),

                    SizedBox(height: getHeight(context, 0.01)),

                    // Empty list when searching
                    if (filteredNotes.isEmpty && searchQuery.isNotEmpty)
                      EmptySearchResult(
                        text: "No notes found matching\n\"$searchQuery\"",
                      ),

                    // Gridview
                    if ((view == "Small Grid" || view == "Large Grid") &&
                        filteredNotes.isNotEmpty)
                      _BuildNotesGrid(
                        onTapNote: (Note note) => onTapNote(note),

                        onLongPressNote: (Note note) => onLongPressNote(note),

                        ungroupedNotesList: filteredNotes,
                        activeReminderUids: _activeReminderUids,
                        selectedView: view,
                        selectedNoteUidList: selectedNoteUidList,
                        gridCount: gridCount,
                      )
                    else
                      // Listview
                      _BuildNotesList(
                        onTapNote: (Note note) => onTapNote(note),

                        onLongPressNote: (Note note) => onLongPressNote(note),

                        ungroupedNotesList: filteredNotes,
                        activeReminderUids: _activeReminderUids,
                        selectedView: view,
                        selectedNoteUidList: selectedNoteUidList,
                      ),
                  ],
                ),

                _BuildMultiNoteSelectMenu(
                  isMany: selectedNoteUidList.length == 1,
                  sSortView: sSortView,

                  onCancel: () async {
                    setState(() {
                      selectedNoteUidList.clear();
                      sSortView = true;
                    });
                  },

                  onDelete: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return DeleteConfirmation(
                          singleDeletion: selectedNoteUidList.length > 1
                              ? false
                              : true,
                          yesAction: () async {
                            // Cancel reminder
                            await reminderController.cancelReminders(
                              uidList: selectedNoteUidList,
                            );

                            await noteController.deleteMultipleNotes(
                              uidlist: selectedNoteUidList,
                            );

                            setState(() {
                              selectedNoteUidList.clear();
                              sSortView = true;
                            });
                          },
                        );
                      },
                    );
                  },

                  onTapFolder: () async {
                    final int groupCount = await groupController
                        .getTotalGroupCount();

                    if (groupCount > 0) {
                      // Show dialog with two options
                      // 1. New group
                      // 2. Add to existing group
                      if (!context.mounted) return;

                      await showDialog(
                        context: context,
                        builder: (context) {
                          return OptionDialog(
                            titleText: 'Folder Options',

                            option1Text: 'New Folder',
                            onTapOption1: () async {
                              // Close dialog
                              Navigator.pop(context);
                              // Go to AddEditGroup screen
                              await goToAddEditGroupScreen();
                            },

                            option2Text: 'Add to Existing folder',
                            onTapOption2: () async {
                              // Close dialog
                              Navigator.pop(context);

                              List<Group> existingGroupsList =
                                  await groupController.getAllGroups();

                              if (!context.mounted) return;

                              // Open new BottomSheet showing existing folders cards
                              final result = await showModalBottomSheet(
                                context: context,
                                useSafeArea: true,
                                isScrollControlled: true,
                                isDismissible: false,
                                sheetAnimationStyle: AppTheme.animationStyle(),
                                shape: AppTheme.roundedRectangleBorder(),
                                builder: (context) {
                                  return _BuildGroupList(
                                    existingGroupsList: existingGroupsList,
                                    onTapGroup: (Group selectedGroup) async {
                                      await noteController.groupSelectedNotes(
                                        uidList: selectedNoteUidList,
                                        gName: selectedGroup.gName,
                                      );

                                      int currentCount =
                                          selectedGroup.noteCount;
                                      // The [...] operator copies the elements into a brand new, growable List
                                      List<String> currentUidList = [
                                        ...?selectedGroup.notesUidsList,
                                        ...selectedNoteUidList,
                                      ];

                                      // Update group object
                                      selectedGroup.noteCount =
                                          currentCount +
                                          selectedNoteUidList.length;
                                      selectedGroup.notesUidsList =
                                          currentUidList;

                                      // Insert updated group
                                      await groupController.updateGroupNoteInfo(
                                        selectedGroup,
                                      );

                                      if (!context.mounted) return;

                                      Navigator.pop(context, "Added");
                                    },
                                  );
                                },
                              );

                              if (result.toString() == "Added") {
                                setState(() {
                                  selectedNoteUidList.clear();
                                  sSortView = true;
                                });
                              }
                            },
                          );
                        },
                      );
                    }
                    // When groupCount = 0
                    else {
                      // Go to AddEditGroup screen
                      await goToAddEditGroupScreen();
                    }
                  },

                  onTapShare: () async {
                    Note note = normalNotesList
                        .where((n) => n.uid == selectedNoteUidList.first)
                        .toList()
                        .first;

                    final status = await showModalBottomSheet<String>(
                      useSafeArea: true,
                      isDismissible: false,
                      isScrollControlled: true,
                      sheetAnimationStyle: AppTheme.animationStyle(),
                      shape: AppTheme.roundedRectangleBorder(),
                      context: context,
                      builder: (context) => VShare(note: note),
                    );

                    if (status == SharedStatus.shared.name) {
                      setState(() {
                        selectedNoteUidList.clear();
                        sSortView = true;
                      });
                    }
                  },

                  onTapReminder: () async {
                    Note note = normalNotesList
                        .where(
                          (n) => n.uid.toString() == selectedNoteUidList.first,
                        )
                        .toList()
                        .first;

                    final String? reminder = await showModalBottomSheet(
                      useSafeArea: true,
                      isDismissible: false,
                      isScrollControlled: true,
                      sheetAnimationStyle: AppTheme.animationStyle(),
                      shape: AppTheme.roundedRectangleBorder(),
                      context: context,
                      builder: (context) => VReminder(note: note),
                    );

                    if (reminder != null) reminderStatus(reminder);
                  },
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: sSortView
          ? FloatingActionButton(
              onPressed: () async {
                final noteType = await showNoteTypeDialog(context);

                if (!context.mounted || noteType == null) return;

                // Open text note screen or checklist screen based on noteType
                Navigator.pushNamed(
                  context,
                  noteType == NoteType.text
                      ? Routes.addEditNote
                      : Routes.addEditCheckListNote,
                  arguments: AddEditNoteArgs(edit: false),
                );
              },
              child: const Icon(Icons.note_add_rounded),
            )
          : null,
    );
  }

  Future<void> _loadReminders() async {
    final reminders = await reminderController.getAllReminder();

    if (reminders.isEmpty) return;

    // Extract the noteUID from the reminder object
    final noteUids = reminders.map((r) => r.noteUID.toString()).toList();

    // Pass the UID list to check and find notes with reminders
    final uids = await notificationService.getNotesWithReminders(noteUids);

    if (!mounted) return;

    setState(() {
      _activeReminderUids = uids.toSet();
    });
  }

  void reminderStatus(String reminder) {
    final uid = selectedNoteUidList.first;

    setState(() {
      // Create a fresh copy of the set to guarantee a UI rebuild
      final updatedReminders = Set<String>.from(_activeReminderUids);

      if (reminder == "scheduled" || reminder == "pinned") {
        updatedReminders.add(uid);
      } else if (reminder == "cancel") {
        updatedReminders.remove(uid);
      }

      // Reassign the state variable
      _activeReminderUids = updatedReminders;
      selectedNoteUidList.clear();
      sSortView = true;
    });
  }

  // Extracted search function with debouncer
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        searchQuery = value;
      });
    });
  }

  void initializeViewType() async {
    final String viewType = await SharedPrefService.getViewType();
    if (viewType != "") {
      setState(() {
        view = viewType;
      });
      changeView();
    }
  }

  void initializeSortType() async {
    final String sortType = await SharedPrefService.getSortType();
    if (sortType != "") {
      setState(() {
        sort = sortType;
      });
      logger.d(sort);
      _notesStream = noteController.listenToNoteSchema(sort);
    }
  }

  void onTapNote(Note note) {
    if (selectedNoteUidList.isEmpty) {
      // Edit
      navigate(note);
    } else {
      // Select note
      if (selectedNoteUidList.contains(note.uid.toString())) {
        selectedNoteUidList.remove(note.uid.toString());
        if (selectedNoteUidList.isEmpty) {
          sSortView = true;
        }
        setState(() {});
      } else {
        setState(() {
          selectedNoteUidList.add(note.uid.toString());
          sSortView = false;
        });
      }
    }
  }

  void onLongPressNote(Note note) {
    // When any note is not selected.
    if (selectedNoteUidList.isEmpty) {
      if (selectedNoteUidList.contains(note.uid.toString())) {
        selectedNoteUidList.remove(note.uid.toString());
        if (selectedNoteUidList.isEmpty) {
          sSortView = true;
        }
        setState(() {});
      } else {
        setState(() {
          selectedNoteUidList.add(note.uid.toString());
          sSortView = false;
        });
      }
    }
  }

  Future<void> goToAddEditGroupScreen() async {
    final result = await Navigator.pushNamed(
      context,
      Routes.addEditGroup,
      arguments: AddEditGroupArgs(
        edit: false,
        selectedNoteUidList: selectedNoteUidList,
      ),
    );

    if (result.toString() == "Added") {
      setState(() {
        selectedNoteUidList.clear();
        sSortView = true;
      });
    }
  }

  void changeView() {
    switch (view) {
      case "Small Grid":
        setState(() => gridCount = 3);
        break;
      case "Large Grid":
        setState(() => gridCount = 2);
        break;
      default:
    }
    logger.d(view);
  }

  void showSortBottomSheet() async {
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

    Future.delayed(Duration(seconds: 2));

    if (result != null && result.isNotEmpty) {
      await SharedPrefService.saveSortType(result);
      if (result != sort) {
        setState(() {
          sort = result;
        });
        logger.d(sort);
        _notesStream = noteController.listenToNoteSchema(sort);
      }
    }
  }

  void showViewBottomSheet() async {
    final result = await showModalBottomSheet<String>(
      useSafeArea: true,
      sheetAnimationStyle: AppTheme.animationStyle(),
      shape: AppTheme.roundedRectangleBorder(),
      context: context,
      builder: (context) => SortViewOptions(
        title: 'View',
        options: viewOptions,
        showIcons: true,
        currentSelected: view,
      ),
    );

    if (result != null && result.isNotEmpty) {
      await SharedPrefService.saveViewType(result);
      if (result != view) {
        setState(() {
          view = result;
        });
        changeView();
      }
    }
  }

  Future<void> navigate(Note note) async {
    // Open text note screen or checklist screen based on noteType
    await Navigator.pushNamed(
      context,
      note.isCheckList ? Routes.addEditCheckListNote : Routes.addEditNote,
      arguments: AddEditNoteArgs(edit: true, eNote: note),
    );

    if (!mounted) return;

    await _loadReminders();
  }
}

// Stateless Widgets
class _BuildNotesList extends StatelessWidget {
  final Function(Note) onTapNote;
  final Function(Note) onLongPressNote;
  final List<Note> ungroupedNotesList;
  final Set<String> activeReminderUids;
  final String selectedView;
  final List<String> selectedNoteUidList;

  const _BuildNotesList({
    required this.onTapNote,
    required this.onLongPressNote,
    required this.ungroupedNotesList,
    required this.selectedView,
    required this.selectedNoteUidList,
    required this.activeReminderUids,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        physics: const BouncingScrollPhysics(),
        itemCount: ungroupedNotesList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final note = ungroupedNotesList[index];
          bool selected = selectedNoteUidList.contains(note.uid.toString());
          final hasReminder = activeReminderUids.contains(note.uid.toString());

          final Color decorColor = note.color;

          return GestureDetector(
            onLongPress: () {
              onLongPressNote(note);
            },
            onTap: () {
              onTapNote(note);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              height: selectedView == "Title"
                  ? getHeight(context, 0.08)
                  : getHeight(context, 0.2),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _NoteCard(
                    note: note,
                    isSelected: selected,
                    decorColor: decorColor,
                    view: selectedView,
                  ),
                  if (hasReminder) ReminderIcon(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BuildNotesGrid extends StatelessWidget {
  final Function(Note) onTapNote;
  final Function(Note) onLongPressNote;
  final List<Note> ungroupedNotesList;
  final Set<String> activeReminderUids;
  final String selectedView;
  final List<String> selectedNoteUidList;
  final int gridCount;

  const _BuildNotesGrid({
    required this.onTapNote,
    required this.onLongPressNote,
    required this.ungroupedNotesList,
    required this.selectedView,
    required this.selectedNoteUidList,
    required this.gridCount,
    required this.activeReminderUids,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCount,
          mainAxisSpacing: selectedView == "Small Grid" ? 6 : 12,
          crossAxisSpacing: selectedView == "Small Grid" ? 6 : 12,
          childAspectRatio: 1,
        ),
        itemCount: ungroupedNotesList.length,
        itemBuilder: (context, index) {
          final note = ungroupedNotesList[index];
          bool selected = selectedNoteUidList.contains(note.uid.toString());
          final hasReminder = activeReminderUids.contains(note.uid.toString());

          final Color decorColor = note.color;

          return GestureDetector(
            onLongPress: () {
              onLongPressNote(note);
            },
            onTap: () {
              onTapNote(note);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                _NoteCard(
                  note: note,
                  isSelected: selected,
                  decorColor: decorColor,
                  view: selectedView,
                ),
                if (hasReminder) ReminderIcon(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BuildMultiNoteSelectMenu extends StatelessWidget {
  final bool isMany;
  final bool sSortView;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final VoidCallback onTapFolder;
  final VoidCallback onTapShare;
  final VoidCallback onTapReminder;

  const _BuildMultiNoteSelectMenu({
    required this.isMany,
    required this.sSortView,
    required this.onCancel,
    required this.onDelete,
    required this.onTapFolder,
    required this.onTapShare,
    required this.onTapReminder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedOpacity(
      opacity: sSortView ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: sSortView ? const Offset(0, 0.1) : const Offset(0, 0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        child: Align(
          alignment: AlignmentGeometry.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            margin: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.lThirdColor : AppColors.dThirdColor,
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  blurRadius: 5.0,
                  spreadRadius: 3.0,
                  color: isDark
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.dThirdColor.withValues(alpha: 0.5),
                  blurStyle: BlurStyle.outer,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: .min,
              mainAxisAlignment: .center,
              children: [
                _BuildMultiNoteSelectOptions(
                  icon: Icons.cancel,
                  text: "Cancel",
                  onTap: onCancel,
                ),

                _BuildMultiNoteSelectOptions(
                  onTap: onDelete,
                  icon: Icons.delete,
                  text: "Delete",
                ),

                _BuildMultiNoteSelectOptions(
                  onTap: onTapFolder,
                  text: "Folder",
                  icon: Icons.folder,
                ),

                if (isMany) ...[
                  _BuildMultiNoteSelectOptions(
                    onTap: onTapShare,
                    text: "Share",
                    icon: Icons.share,
                  ),

                  _BuildMultiNoteSelectOptions(
                    onTap: onTapReminder,
                    text: "Reminder",
                    icon: Icons.notifications,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BuildMultiNoteSelectOptions extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _BuildMultiNoteSelectOptions({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: getWidth(context, 0.15),
        child: Column(
          crossAxisAlignment: .center,
          mainAxisSize: .min,
          spacing: 3.0,
          children: [
            Icon(icon, color: Colors.white),
            Text(
              text,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: Colors.white,
                fontSize: 11.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildGroupList extends StatelessWidget {
  final List<Group> existingGroupsList;
  final Function(Group) onTapGroup;

  const _BuildGroupList({
    required this.existingGroupsList,
    required this.onTapGroup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: getHeight(context, 0.55),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      decoration: BoxDecoration(
        borderRadius: AppTheme.roundedRectangleBorder().borderRadius,
        color:
            theme.dialogTheme.backgroundColor ??
            (isDark ? AppColors.dThirdColor : AppColors.lFirstColor),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header Row
          Row(
            children: [
              const SizedBox(width: 4),
              Text(
                "Existing Folders",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: theme.appBarTheme.titleTextStyle?.fontFamily,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context, "Cancel"),
                icon: Icon(
                  Icons.cancel_rounded,
                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  size: 28,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Folder Items List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: existingGroupsList.length,
              itemBuilder: (context, index) {
                final group = existingGroupsList[index];
                final Color decorColor = group.color;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: decorColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onTapGroup(group),
                      borderRadius: BorderRadius.circular(14),
                      child: Row(
                        children: [
                          // Dynamic Color Indicator Bar on the left side
                          Container(width: 6, height: 72, color: decorColor),
                          const SizedBox(width: 14),

                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: decorColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.folder_copy_rounded,
                              color: decorColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Text Segment Blocks
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  group.gName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Notes: ${group.noteCount}",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Trailing navigation accent hint arrow
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final Color decorColor;
  final String view;

  const _NoteCard({
    required this.note,
    required this.isSelected,
    required this.decorColor,
    required this.view,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: AppTheme.noteTheme(
        isDark: isDark,
        isSelected: isSelected,
        decorColor: decorColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: view != "Title"
          ? Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  note.title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                DisplayContent(note: note),
                if (view != "Small Grid") ...[
                  Divider(
                    height: 16,
                    color: textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                  ),
                  Row(
                    children: [
                      Spacer(),
                      Text(
                        "${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}",
                        style: textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            )
          : Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Text(
                note.title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
    );
  }
}
