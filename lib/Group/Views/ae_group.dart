import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/Group/Model/m_group.dart';
import 'package:tasknote/Note/note_functions.dart';
import 'package:tasknote/Other_Views/v_splash.dart';

class AddEditGroupArgs {
  // When Edit
  final bool edit;
  final Group? eGroup;

  // When Add
  final List<String>? selectedNoteUidList;

  AddEditGroupArgs({required this.edit, this.eGroup, this.selectedNoteUidList});
}

class AddEditGroup extends StatefulWidget {
  // When Edit
  final bool edit;
  final Group? eGroup;

  // When Add
  final List<String>? selectedNoteUidList;

  const AddEditGroup({
    super.key,
    required this.edit,
    this.eGroup,
    this.selectedNoteUidList,
  });

  @override
  State<AddEditGroup> createState() => _AddEditGroupState();
}

class _AddEditGroupState extends State<AddEditGroup> {
  late String title, decorColor, formButtonText;
  late TextEditingController cName, cDescription;
  late DateTime createdAt, updatedAt;

  late final AppLifecycleListener _lifecycleListener;

  final _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocusNode = FocusNode();

  bool isEditing = false;

  bool _shouldPopOnResume = false;

  @override
  void initState() {
    super.initState();

    // Initialize the listener to monitor app state changes
    _lifecycleListener = AppLifecycleListener(
      onPause: _handleBackgroundAction,
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
      title = "Edit Folder";
      formButtonText = "Save";
      cName = TextEditingController(text: widget.eGroup!.gName);
      cDescription = TextEditingController(text: widget.eGroup!.description);
      createdAt = widget.eGroup!.createdAt;
      updatedAt = widget.eGroup!.updatedAt;
      decorColor = widget.eGroup!.decorColor.toString();
    } else {
      isEditing = false;
      title = "Add Folder";
      formButtonText = "Add";
      cName = TextEditingController();
      cDescription = TextEditingController();
      createdAt = DateTime.now();
      updatedAt = DateTime.now();
      decorColor = decorColor = uniqueColors[0].toARGB32().toRadixString(16);
    }
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();

    cName.dispose();
    cDescription.dispose();

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
            actions:
                widget
                    .edit // Edit mode
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
                              _nameFocusNode.requestFocus();
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

                    // Delete button
                    Visibility(
                      visible: widget.edit && isEditing,
                      child: IconButton(
                        onPressed: () async {
                          debugPrint('Delete pressed');
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return DeleteConfirmation(
                                singleDeletion: true,
                                item: "folder",
                                nCount: widget.eGroup!.noteCount,
                                yesAction: () async {
                                  // Cancel reminder
                                  await reminderController.cancelReminders(
                                    uidList: widget.eGroup!.notesUidsList!,
                                  );

                                  // Delete notes inside group
                                  await noteController.deleteMultipleNotes(
                                    uidlist: widget.eGroup!.notesUidsList!,
                                  );

                                  // Delete group
                                  await groupController.deleteGroup(
                                    widget.eGroup!.id,
                                  );

                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ),
                  ]
                : // Add mode
                  [
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
                    _nameFocusNode.requestFocus();
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
                      if (widget.edit) ...[
                        DatesRow(
                          updated: NoteFunctions.formatCustom(
                            updatedAt,
                            short: true,
                          ),
                          created: NoteFunctions.formatCustom(createdAt),
                        ),
                        SizedBox(height: getHeight(context, 0.050)),
                      ],

                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CLabel(text: "Name"),
                            CTextFormField(
                              controller: cName,
                              label: "Name",
                              focusNode: _nameFocusNode,
                              readOnly: isEditing,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(titlePattern),
                              ],
                            ),
                            SizedBox(height: getHeight(context, 0.030)),
                            CLabel(text: "Description"),
                            CTextFormField(
                              readOnly: isEditing,
                              controller: cDescription,
                              label: "Description",
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

  Future<void> _handleBackgroundAction() async {
    logger.d("Task started in background");
    await _silentSaveInBackground();
    logger.d("Task completed in background");
  }

  Future<void> _silentSaveInBackground() async {
    // Skip form validation UI. Just make sure there is text to save.
    if (cName.text.trim().isEmpty && cDescription.text.trim().isEmpty) return;

    final group = _buildGroupFromCurrentState();
    bool success = false; // Track if the operation succeeded

    // Edit group
    if (widget.edit) {
      // Save changes silently if any exist
      if (_hasChanges(widget.eGroup!, group)) {
        success = await groupController.checkAndUpdateGroup(
          oldGroup: widget.eGroup!,
          newGroup: group,
        );
      } else {
        success = false; // No changes, so mark as false
      }
    }
    // Add group
    else {
      // Add feature
      success = await groupController.checkAndAddGroup(
        group: group,
        context: context,
      );

      await noteController.groupSelectedNotes(
        uidList: widget.selectedNoteUidList!,
        gName: group.gName,
      );
    }

    // If the group saved successfully, prepare to close the screen
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
  }

  Future<void> _onTapSaveOrUpdate({bool isFromBackButton = false}) async {
    if (isFromBackButton &&
        cName.text.trim().isEmpty &&
        cDescription.text.trim().isEmpty) {
      if (context.mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
      return; // Stop execution here
    }

    if (_formKey.currentState!.validate()) {
      final group = _buildGroupFromCurrentState();

      // Edit group
      if (widget.edit) {
        // Check if name or description or color is changed
        if (_hasChanges(widget.eGroup!, group)) {
          bool updated = await groupController.checkAndUpdateGroup(
            oldGroup: widget.eGroup!,
            newGroup: group,
            context: context,
          );

          if (updated) {
            if (!mounted) return;
            Navigator.pop(context, "Edited");
          }
        } else {
          // NO CHANGES DETECTED:
          // Skip the database update, but STILL let the user leave the screen!
          Navigator.pop(context);
        }
      }
      // Add group
      else {
        // Add feature
        bool added = await groupController.checkAndAddGroup(
          group: group,
          context: context,
        );

        await noteController.groupSelectedNotes(
          uidList: widget.selectedNoteUidList!,
          gName: group.gName,
        );

        if (added) {
          if (!mounted) return;
          Navigator.pop(context, "Added");
        }
      }
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

  Group _buildGroupFromCurrentState() {
    final group = Group(
      gName: cName.text.toString().trim(),
      description: cDescription.text.toString().trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      decorColor: decorColor,
    );

    if (widget.edit) {
      // Edit mode
      group.createdAt = widget.eGroup!.createdAt;
      group.noteCount = widget.eGroup!.noteCount;
      group.notesUidsList = widget.eGroup!.notesUidsList;
    } else {
      // Add mode
      group.noteCount = widget.selectedNoteUidList!.length;
      group.notesUidsList = widget.selectedNoteUidList!;
    }

    return group;
  }

  bool _hasChanges(Group oldGroup, Group newGroup) {
    if (oldGroup.gName != newGroup.gName) {
      return true;
    }
    if (oldGroup.description != newGroup.description) {
      return true;
    }
    if (oldGroup.decorColor != newGroup.decorColor) {
      return true;
    }
    return false;
  }
}
