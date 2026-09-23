import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tasknote/Note/common.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Service/s_notification.dart';
import 'package:tasknote/Other/routes.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/Note/Views/v_note_types.dart';
import 'package:tasknote/Reminder/v_reminder.dart';
import 'package:tasknote/Share/v_share.dart';
import 'package:tasknote/Other_Views/v_splash.dart';

class VCalenderNote extends StatefulWidget {
  const VCalenderNote({super.key});

  @override
  State<VCalenderNote> createState() => _VCalenderNoteState();
}

class _VCalenderNoteState extends State<VCalenderNote> {
  String sort = "Last updated";
  late Stream<List<Note>> _calNotesStream;

  DateTime _selectedDT = DateTime.now(); // Selected day
  DateTime _focusedDT = DateTime.now(); // Focused day / Current Month

  @override
  void initState() {
    super.initState();
    _calNotesStream = noteController.listenToCalNoteSchema();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: StreamBuilder<List<Note>>(
          stream: _calNotesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final sortedCalNoteList = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                rowHeight: MediaQuery.sizeOf(context).height / 10,
                daysOfWeekHeight: MediaQuery.sizeOf(context).height / 20,
                focusedDay: _focusedDT,
                pageJumpingEnabled: true,
                selectedDayPredicate: (day) => isSameDay(_selectedDT, day),
                onDaySelected: (selectedDay, focusedDay) async {
                  setState(() {
                    _selectedDT = selectedDay;
                    _focusedDT = focusedDay;
                  });

                  final String? result = await showDialog(
                    context: context,
                    builder: (context) {
                      return OptionDialog(
                        titleText: noteController.formatDate(_selectedDT),
                        option1Text: "Add Note",
                        option2Text: "View Notes",

                        onTapOption1: () => Navigator.pop(context, "Add Note"),

                        onTapOption2: () =>
                            Navigator.pop(context, "View Notes"),
                      );
                    },
                  );

                  if (result == null) return;

                  if (result == "Add Note" && context.mounted) {
                    final noteType = await showNoteTypeDialog(context);

                    if (!context.mounted || noteType == null) return;

                    // Open text note screen or checklist screen based on noteType
                    Navigator.pushNamed(
                      context,
                      noteType == NoteType.text
                          ? Routes.addEditNote
                          : Routes.addEditCheckListNote,
                      arguments: AddEditNoteArgs(
                        edit: false,
                        calNote: true,
                        selected: _selectedDT,
                      ),
                    );
                  } else if (result == "View Notes" && context.mounted) {
                    showModalBottomSheet(
                      context: context,
                      isDismissible: false,
                      isScrollControlled: true,
                      sheetAnimationStyle: AppTheme.animationStyle(),
                      shape: AppTheme.roundedRectangleBorder(),
                      builder: (context) {
                        return ViewNoteList(
                          sortedCalNoteList: sortedCalNoteList,
                          selectedDT: _selectedDT,
                        );
                      },
                    );
                  }
                },
                eventLoader: (currentDT) {
                  return noteController.getCalNotesForDay(
                    sortedCalNoteList: sortedCalNoteList,
                    current: currentDT,
                  );
                  // Return events for each day if exists.
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDT = focusedDay;
                  });
                },
                firstDay: DateTime.utc(2000, 01, 01),
                lastDay: DateTime.utc(_selectedDT.year + 75, 12, 31),
                calendarFormat: CalendarFormat.month,
                daysOfWeekStyle: AppTheme.daysOfWeekStyle(
                  borderColor: isDark ? Colors.white : Colors.black,
                  textColor: isDark ? AppColors.primary : AppColors.lThirdColor,
                ),
                calendarStyle: AppTheme.calendarStyle(
                  textColor: isDark ? Colors.white : Colors.black,
                  borderColor: isDark ? Colors.white60 : Colors.black54,
                ),
                headerStyle: AppTheme.headerStyle(
                  titleColor: isDark ? Colors.white : Colors.black,
                ),
                onHeaderTapped: (DateTime d) async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDT,
                    firstDate: DateTime.utc(2000, 01, 01),
                    lastDate: DateTime.utc(d.year + 75, 12, 31),
                  );

                  if (picked != null && picked != _selectedDT) {
                    setState(() {
                      _selectedDT = picked;
                      _focusedDT = picked;
                    });
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class ViewNoteList extends StatefulWidget {
  final List<Note> sortedCalNoteList;
  final DateTime selectedDT;

  const ViewNoteList({
    super.key,
    required this.sortedCalNoteList,
    required this.selectedDT,
  });

  @override
  State<ViewNoteList> createState() => _ViewNoteListState();
}

class _ViewNoteListState extends State<ViewNoteList> {
  final NotificationService notificationService = NotificationService();

  List<String> selectedNoteUidList = [];
  List<Note> notesList = [];
  List<String> noteUidList = [];
  Future<List<String>>? _remindersFuture; // Cache the Future here

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(covariant ViewNoteList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate only if the source lists or dates change
    if (oldWidget.sortedCalNoteList != widget.sortedCalNoteList ||
        oldWidget.selectedDT != widget.selectedDT) {
      _initializeData();
    }
  }

  void _initializeData() {
    // Compute the underlying arrays EXACTLY ONCE
    notesList = noteController.getCalNotesForDay(
      sortedCalNoteList: widget.sortedCalNoteList,
      current: widget.selectedDT,
    );

    noteUidList = notesList.map((note) => note.uid.toString()).toList();

    // Cache the future so FutureBuilder doesn't continuously restart
    _remindersFuture = notificationService.getNotesWithReminders(noteUidList);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool hasNoNotes = notesList.isEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
      ),
      height: hasNoNotes ? getHeight(context, 0.2) : getHeight(context, 0.5),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: getWidth(context, 0.1)),
              Expanded(
                child: Text(
                  "Notes",
                  style: theme.textTheme.bodyMedium!.copyWith(fontSize: 20.0),
                  textAlign: TextAlign.start,
                ),
              ),
              Align(
                alignment: AlignmentGeometry.topRight,
                child: Row(
                  spacing: 10.0,
                  children: [
                    // Show selected count, Delete Multiple cal note
                    if (selectedNoteUidList.isNotEmpty) ...[
                      // Show selected count
                      SelectedCount(
                        text:
                            "${selectedNoteUidList.length} / ${notesList.length}",
                      ),

                      // Delete Multiple cal note
                      IconButton(
                        onPressed: () async {
                          Navigator.pop(context);
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

                                  selectedNoteUidList.clear();
                                },
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],

                    // Add calnote
                    if (selectedNoteUidList.isEmpty)
                      IconButton(
                        onPressed: () async {
                          final noteType = await showNoteTypeDialog(context);

                          if (!context.mounted || noteType == null) return;

                          Navigator.pop(context);

                          // Open text note screen or checklist screen based on noteType
                          Navigator.pushNamed(
                            context,
                            noteType == NoteType.text
                                ? Routes.addEditNote
                                : Routes.addEditCheckListNote,
                            arguments: AddEditNoteArgs(
                              edit: false,
                              calNote: true,
                              selected: widget.selectedDT,
                            ),
                          );
                        },
                        icon: Icon(Icons.note_add_rounded),
                      ),

                    // Cancel Dialog
                    IconButton(
                      onPressed: () {
                        if (selectedNoteUidList.isNotEmpty) {
                          selectedNoteUidList.clear();
                          setState(() {});
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      icon: selectedNoteUidList.isEmpty
                          ? Icon(Icons.cancel)
                          : Icon(Icons.cancel, color: theme.colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (hasNoNotes)
            Expanded(child: Center(child: Text("No notes added"))),

          if (!hasNoNotes)
            Expanded(
              child: FutureBuilder(
                future: _remindersFuture,
                builder: (context, reminderSnapshot) {
                  if (reminderSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // This is the list containing only the UIDs of notes that have reminders
                  final List<String> notesWithReminders =
                      reminderSnapshot.data ?? [];

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: notesList.length,
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    physics: BouncingScrollPhysics(),

                    itemBuilder: (context, index) {
                      final note = notesList[index];
                      final hasReminder = notesWithReminders.contains(note.uid);

                      return GestureDetector(
                        onLongPress: () {
                          onLongPressNote(note);
                        },
                        onTap: () {
                          onTapNote(note);
                        },
                        child: _BuildNoteCard(
                          note: note,
                          isSelected: selectedNoteUidList.contains(
                            note.uid.toString(),
                          ),
                          hasReminder: hasReminder,
                          selectedCount: selectedNoteUidList.length,
                          onTapShare: () async {
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
                              });

                              if (!context.mounted) return;
                              Navigator.pop(context);
                            }
                          },
                          onTapReminder: () async {
                            final reminder = await showModalBottomSheet<String>(
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
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void reminderStatus(String reminder) {
    if (reminder == "pinned" ||
        reminder == "scheduled" ||
        reminder == "cancel") {
      setState(() {
        selectedNoteUidList.clear();

        // RE-FETCH THE FUTURE HERE SO THE UI REBUILDS WITH/WITHOUT THE ICON
        _remindersFuture = notificationService.getNotesWithReminders(
          noteUidList,
        );
      });
    }
  }

  void onTapNote(Note note) async {
    if (selectedNoteUidList.isEmpty) {
      Navigator.pop(context);

      // Edit
      // Open text note screen or checklist screen based on noteType
      Navigator.pushNamed(
        context,
        note.isCheckList ? Routes.addEditCheckListNote : Routes.addEditNote,
        arguments: AddEditNoteArgs(edit: true, eNote: note, calNote: true),
      );
    } else {
      // When any note is selected.
      if (selectedNoteUidList.contains(note.uid.toString())) {
        setState(() {
          selectedNoteUidList.remove(note.uid.toString());
        });
      } else {
        setState(() {
          selectedNoteUidList.add(note.uid.toString());
        });
      }
    }
  }

  void onLongPressNote(Note note) async {
    if (selectedNoteUidList.isEmpty) {
      setState(() {
        selectedNoteUidList.add(note.uid.toString());
      });
    }
  }
}

// Stateless Widgets
class _BuildNoteCard extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final bool hasReminder;
  final int selectedCount;
  final VoidCallback onTapShare;
  final VoidCallback onTapReminder;

  const _BuildNoteCard({
    required this.note,
    required this.isSelected,
    required this.selectedCount,
    required this.onTapShare,
    required this.onTapReminder,
    required this.hasReminder,
  });

  @override
  Widget build(BuildContext context) {
    final Color decorColor = note.color;

    return Stack(
      children: [
        _NoteCard(note: note, isSelected: isSelected, decorColor: decorColor),
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Note Reminder, Share note
              if (selectedCount == 1 && isSelected) ...[
                // Note Reminder
                InkWell(onTap: onTapReminder, child: Icon(Icons.notifications)),

                SizedBox(width: 10),

                // Share note
                InkWell(onTap: onTapShare, child: Icon(Icons.share)),
              ],

              // Reminder Status Icon (Always at the far right if active)
              if (hasReminder) ...[
                SizedBox(width: 10),
                ReminderIcon(position: true),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final Color decorColor;

  const _NoteCard({
    required this.note,
    required this.isSelected,
    required this.decorColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: getHeight(context, 0.18)),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        decoration: AppTheme.noteTheme(
          isDark: isDark,
          isSelected: isSelected,
          decorColor: decorColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Column(
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
        ),
      ),
    );
  }
}
