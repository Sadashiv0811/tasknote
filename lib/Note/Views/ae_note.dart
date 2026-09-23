import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:tasknote/Note/common.dart';
import 'package:tasknote/Service/s_notification.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/User/Model/m_user.dart';
import 'package:tasknote/Note/note_functions.dart';
import 'package:tasknote/Reminder/v_reminder.dart';
import 'package:tasknote/Share/v_share.dart';
import 'package:tasknote/Other_Views/v_splash.dart';

class AddEditNote extends StatefulWidget {
  final bool edit;
  final Note? eNote;
  // For Calender
  final bool? calNote;
  final DateTime? selected;
  // For Group
  final bool? groupNote;
  final int? groupId;

  const AddEditNote({
    super.key,
    required this.edit,
    this.eNote,
    this.calNote,
    this.selected,
    this.groupNote,
    this.groupId,
  });

  @override
  State<AddEditNote> createState() => _AddEditNoteState();
}

class _AddEditNoteState extends State<AddEditNote> {
  late String title, decorColor;
  late TextEditingController cTitle, cContent;
  late DateTime createdAt, updatedAt;

  late final AppLifecycleListener _lifecycleListener;

  final _formKey = GlobalKey<FormState>();
  final FocusNode _titleFocusNode = FocusNode();
  final NotificationService notificationService = NotificationService();

  bool isEditing = false;

  bool _shouldPopOnResume = false;

  MUser? user;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();

    checkUser();

    // Initialize the listener to monitor app state changes
    _lifecycleListener = AppLifecycleListener(
      onPause: _silentSaveInBackground,
      // Triggered when app goes to background
      onResume: () {
        if (_shouldPopOnResume && mounted) {
          _shouldPopOnResume = false; // Reset the flag
          Navigator.pop(context, widget.edit ? "Edited" : "Added");
        }
      },
    );

    if (widget.edit) {
      isEditing = true;
      title = "Edit Note";
      cTitle = TextEditingController(text: widget.eNote!.title);
      cContent = TextEditingController(text: widget.eNote!.content);
      createdAt = widget.eNote!.createdAt;
      updatedAt = widget.eNote!.updatedAt;
      decorColor = widget.eNote!.decorColor.toString();
    } else {
      isEditing = false;
      title = "Add Note";
      cTitle = TextEditingController();
      cContent = TextEditingController();
      createdAt = DateTime.now();
      updatedAt = DateTime.now();
      decorColor = uniqueColors[0].toARGB32().toRadixString(16);
    }
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();

    cTitle.dispose();
    cContent.dispose();

    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    // Convert the string back to a Color object for the UI
    final currentColor = Color(int.parse("0x$decorColor"));

    return PopScope(
      canPop: false, // Prevents the default back button behavior
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If it already popped somehow, do nothing

        // Save/update logic when the user presses back
        _onTapSaveOrUpdate(isFromBackButton: true);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,

          appBar: AppBar(
            title: Text(title),
            actions: widget.edit
                // Edit mode
                ? [
                    // Edit button
                    Visibility(
                      visible: isEditing,
                      child: IconButton(
                        onPressed: () async {
                          if (isEditing) {
                            setState(() {
                              isEditing = false;
                            });

                            Future.microtask(() {
                              _titleFocusNode.requestFocus();
                            });
                          }
                        },
                        icon: Icon(Icons.edit),
                      ),
                    ),

                    // Save button
                    Visibility(
                      visible: widget.edit && !isEditing,
                      child: IconButton(
                        onPressed: () async {
                          _onTapSaveOrUpdate();
                        },
                        icon: Icon(Icons.done),
                      ),
                    ),

                    // Delete, Share, Reminder, Lock button
                    Visibility(
                      visible: widget.edit && isEditing,
                      child: NotePopupMenu(
                        isProtected: widget.eNote!.isProtected,
                        shareCB: () async {
                          Note note = widget.eNote!;

                          note.title = cTitle.text.trim();
                          note.content = cContent.text.trim();

                          await showModalBottomSheet(
                            useSafeArea: true,
                            isDismissible: false,
                            isScrollControlled: true,
                            sheetAnimationStyle: AppTheme.animationStyle(),
                            shape: AppTheme.roundedRectangleBorder(),
                            context: context,
                            builder: (context) => VShare(note: note),
                          );
                        },
                        deleteCB: () async {
                          logger.d('Delete pressed');
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return DeleteConfirmation(
                                singleDeletion: true,
                                yesAction: () async {
                                  await NoteFunctions.singleNoteDelete(
                                    eNote: widget.eNote!,
                                  );

                                  if (!context.mounted) return;

                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                        reminderCB: () async {
                          Note note = widget.eNote!;
                          
                          note.title = cTitle.text.trim();
                          note.content = cContent.text.trim();

                          final status = await showModalBottomSheet<String>(
                            useSafeArea: true,
                            isDismissible: false,
                            isScrollControlled: true,
                            sheetAnimationStyle: AppTheme.animationStyle(),
                            shape: AppTheme.roundedRectangleBorder(),
                            context: context,
                            builder: (context) => VReminder(note: note),
                          );

                          if (status != null) {
                            reminderStatus(status);
                          }
                        },
                        lockCB: widget.eNote!.isProtected
                            ? () {}
                            : () async {
                                await NoteFunctions.handleLockPressed(
                                  LockNote(
                                    context: context,
                                    isLoggedIn: loggedIn,
                                    title: cTitle.text.trim(),
                                    content: cContent.text.trim(),
                                    user: user,
                                    eNote: widget.eNote,
                                  ),
                                );
                              },
                      ),
                    ),
                  ]
                // Add mode
                : [
                    IconButton(
                      onPressed: () async {
                        _onTapSaveOrUpdate();
                      },
                      icon: Icon(Icons.done),
                    ),
                    SizedBox(width: 10),
                  ],
          ),

          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: () {
                if (isEditing) {
                  setState(() {
                    isEditing = false;
                  });

                  Future.microtask(() {
                    _titleFocusNode.requestFocus();
                  });
                }
              },

              child: SizedBox(
                height: double.infinity,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      if (widget.edit && widget.eNote != null) ...[
                        DatesRow(
                          updated: NoteFunctions.formatCustom(
                            updatedAt,
                            short: true,
                          ),
                          created: NoteFunctions.formatCustom(createdAt),
                        ),

                        SizedBox(height: getHeight(context, 0.010)),

                        // Pin
                        PinnedCard(
                          notificationService: notificationService,
                          eNote: widget.eNote,
                        ),

                        // Schedule
                        ScheduledCard(
                          notificationService: notificationService,
                          eNote: widget.eNote,
                        ),
                      ],

                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: getHeight(context, 0.010)),

                            TitleField(
                              isEditing: isEditing,
                              cTitle: cTitle,
                              titleFocusNode: _titleFocusNode,
                            ),

                            SizedBox(height: getHeight(context, 0.030)),

                            CLabel(text: "Content"),
                            CTextFormField(
                              readOnly: isEditing,
                              controller: cContent,
                              label: "Content",
                            ),

                            SizedBox(height: getHeight(context, 0.030)),

                            CLabel(text: "Color"),
                            Center(
                              child: ColorSelector(
                                selectedColor: currentColor,
                                onColorSelected: (color) {
                                  // Only allow changing colors if the screen is NOT in read-only mode
                                  if (!isEditing) {
                                    setState(() {
                                      decorColor = color
                                          .toARGB32()
                                          .toRadixString(16);
                                    });
                                    logger.d(decorColor);
                                  }
                                },
                              ),
                            ),

                            SizedBox(height: getHeight(context, 0.050)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Note object creation
  Note getNoteObject() {
    return NoteFunctions.buildNoteFromCurrentState(
      isEdit: widget.edit,
      title: cTitle.text.toString().trim(),
      content: cContent.text.toString().trim(),
      decorColor: decorColor,
      isCheckList: false,

      isCalNote: widget.calNote ?? false,
      selectedDate: widget.selected,
      isGroupNote: widget.groupNote ?? false,
      eNote: widget.eNote,
    );
  }

  // Background note saving
  Future<void> _silentSaveInBackground() async {
    logger.d("Task started in background");

    // Skip form validation UI. If any field is empty
    if (cTitle.text.trim().isEmpty || cContent.text.trim().isEmpty) return;

    final note = getNoteObject();

    bool success = await NoteFunctions.performAddOrEditInBackground(
      isEdit: widget.edit,
      eNote: widget.eNote!,
      note: note,
      isGrouped: widget.groupNote == true,
      groupId: widget.groupId!,
    );

    // If the note saved successfully, prepare to close the screen
    if (success) {
      _shouldPopOnResume = true;

      // TIMING FAILSAFE: If the user opened the app back up BEFORE the background
      // save completed, pop the screen immediately right now.
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
          mounted) {
        _shouldPopOnResume = false;
        Navigator.pop(context, widget.edit ? "Edited" : "Added");
      }
    }

    logger.d("Task completed in background");
  }

  // User saving note
  Future<void> _onTapSaveOrUpdate({bool isFromBackButton = false}) async {
    if (isFromBackButton &&
        cTitle.text.trim().isEmpty &&
        cContent.text.trim().isEmpty) {
      if (context.mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
      return; // Stop execution here
    }

    if (_formKey.currentState!.validate()) {
      final note = getNoteObject();

      await NoteFunctions.performAddOrEditOnTap(
        isEdit: widget.edit,
        eNote: widget.eNote,
        note: note,
        isGrouped: widget.groupNote!,
        groupId: widget.groupId!,
        context: context,
      );
    } else {
      // Validation failed.
      if (isFromBackButton) {
        // The user pressed the physical back button, so let them leave the screen without saving the invalid data.
        Navigator.pop(context);
      } else {
        // The user pressed the Save button. Do NOTHING.
        // The Form will automatically show the red validation errors on the screen.
      }
    }
  }

  // User related
  Future<void> checkUser() async {
    bool isConnected = await checkInternet();
    final isar = userController.isar;

    // Online
    if (isConnected) {
      // Get the current Firebase Auth user session
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        // Fetch the corresponding custom MUser from Isar using the UID
        final MUser? localUser = await userController.fetchByUid(
          firebaseUser.uid,
        );

        setState(() {
          loggedIn = true;
          user = localUser;
        });
      } else {
        setState(() {
          loggedIn = false;
          user = null;
        });
      }
    }
    // Offline
    else {
      // Offline Fallback: Read the user profile directly from local Isar cache
      final localUser = await isar.mUsers.where().build().findFirst();

      setState(() {
        loggedIn = localUser != null;
        user = localUser;
      });
    }
  }

  // Reminder status check
  void reminderStatus(String reminder) {
    if (reminder == "pinned" || reminder == "scheduled") {
      if (!context.mounted) return;
      setState(() {});
    } else if (reminder == "cancel") {
      if (!context.mounted) return;
      setState(() {});
    }
  }
}
