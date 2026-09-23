import 'package:flutter/material.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/Note/common.dart';
import 'package:tasknote/Note/note_functions.dart';

class EditProtectedNote extends StatefulWidget {
  final Note note;

  const EditProtectedNote({super.key, required this.note});

  @override
  State<EditProtectedNote> createState() => _EditProtectedNoteState();
}

class _EditProtectedNoteState extends State<EditProtectedNote> {
  late TextEditingController cTitle, cContent;
  late DateTime createdAt, updatedAt;
  late String decorColor;

  late final AppLifecycleListener _lifecycleListener;

  bool isEditing = true;
  bool _shouldPopOnResume = false;
  List<CheckNote> list = [];

  // Controls whether the PopScope allows the screen to pop
  bool _canPop = false;

  final _formKey = GlobalKey<FormState>();
  final FocusNode _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Set current note values
    cTitle = TextEditingController(text: widget.note.title);
    cContent = widget.note.isCheckList
        ? TextEditingController()
        : TextEditingController(text: widget.note.content);
    updatedAt = widget.note.updatedAt;
    createdAt = widget.note.createdAt;
    decorColor = widget.note.decorColor.toString();
    list = widget.note.isCheckList
        ? NoteFunctions.convertContentToList(widget.note.content) ?? []
        : [];

    // Initialize the listener to monitor app state changes
    _lifecycleListener = AppLifecycleListener(
      onPause: _handleBackgroundAction,
      onResume: () {
        if (_shouldPopOnResume && mounted) {
          _shouldPopOnResume = false;
          _saveAndPop(
            skipValidation: true,
          ); // Force pop with saved data on resume
        }
      },
    );
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();

    cTitle.dispose();
    cContent.dispose();

    _lifecycleListener.dispose();
    super.dispose();
  }

  /// Centralized method to update the note object properties.
  Note updateNoteObject() {
    Note eNote = widget.note;

    if (eNote.isCheckList) {
      if (cTitle.text.trim().isEmpty) return eNote;

      eNote.content = NoteFunctions.convertListToContent(list) ?? '';
    } else {
      if (cTitle.text.trim().isEmpty && cContent.text.trim().isEmpty) {
        return eNote;
      }

      eNote.content = cContent.text.trim();
    }

    eNote.title = cTitle.text.trim();
    eNote.decorColor = decorColor;
    eNote.updatedAt = DateTime.now();

    return eNote;
  }

  /// Handles the UI action of saving and popping the screen.
  void _saveAndPop({bool skipValidation = false}) {
    final isValid =
        skipValidation || (_formKey.currentState?.validate() ?? true);

    if (isValid) {
      final updatedNote = updateNoteObject();

      // Temporarily allow popping so Navigator.pop doesn't trigger an infinite PopScope loop
      setState(() {
        _canPop = true;
      });

      logger.d(
        "Updated note data\nTitle ${updatedNote.title}\nContent ${updatedNote.content}\nColor ${updatedNote.decorColor}",
      );

      // Wait for the state to register, then pop with the updated note
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop(updatedNote);
        }
      });
    }
  }

  /// Triggered when the app goes to the background.
  Future<void> _handleBackgroundAction() async {
    logger.d("Task started in background");

    updateNoteObject();
    _shouldPopOnResume = true;

    // TIMING FAILSAFE: If the user resumed instantly before this completed
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
        mounted) {
      _shouldPopOnResume = false;
      _saveAndPop(skipValidation: true);
    }

    logger.d("Task completed in background");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Convert the string back to a Color object for the UI
    final currentColor = Color(int.parse("0x$decorColor"));

    return PopScope(
      canPop: _canPop,
      // Prevents the default back button behavior
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // If it already popped somehow, do nothing

        // Back button pressed: Force a save without strict form validation errors,
        // update the object, and pop safely.
        _saveAndPop(skipValidation: true);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,

          appBar: AppBar(
            title: const Text("Edit Protected Note"),
            actions: [
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    if (isEditing) {
                      setState(() {
                        isEditing = false;
                      });

                      Future.microtask(() {
                        _titleFocusNode.requestFocus();
                      });
                    }
                  },
                ),

              if (!isEditing)
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _saveAndPop(skipValidation: false),
                ),
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
                      // Last updated date, Created date
                      if (isEditing) ...[
                        DatesRow(
                          updated: NoteFunctions.formatCustom(
                            updatedAt,
                            short: true,
                          ),
                          created: NoteFunctions.formatCustom(createdAt),
                        ),

                        SizedBox(height: getHeight(context, 0.010)),
                      ],

                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            SizedBox(height: getHeight(context, 0.020)),

                            TitleField(
                              isEditing: isEditing,
                              cTitle: cTitle,
                              titleFocusNode: _titleFocusNode,
                            ),

                            SizedBox(height: getHeight(context, 0.030)),

                            if (widget.note.isCheckList)
                              CheckList(
                                list: list,
                                isEditing: isEditing,
                                titleFocusNode: _titleFocusNode,
                              )
                            else ...[
                              CLabel(text: "Content"),
                              CTextFormField(
                                readOnly: isEditing,
                                controller: cContent,
                                label: "Content",
                              ),
                            ],

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

                            SizedBox(height: getHeight(context, 0.090)),
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
}
