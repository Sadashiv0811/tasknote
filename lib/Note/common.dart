import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tasknote/Note/note_functions.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/Service/s_notification.dart';

// Enums and Classes
enum AddEditTextAction { save, next }

class AddEditTextResult {
  final String value;
  final AddEditTextAction action;

  const AddEditTextResult({required this.value, required this.action});
}

class CheckNote {
  final String title;
  bool isEnabled;

  CheckNote({required this.title, required this.isEnabled});
}

class AddEditNoteArgs {
  final bool edit;
  final Note? eNote;
  final bool? calNote;
  final DateTime? selected;
  final bool? groupNote;
  final int? groupId;

  AddEditNoteArgs({
    required this.edit,
    this.eNote,
    this.calNote = false,
    this.selected,
    this.groupNote = false,
    this.groupId = 0,
  });
}

// Stateful Widgets
class AddEditText extends StatefulWidget {
  final String? text;
  final bool isEdit;

  const AddEditText({super.key, this.text, required this.isEdit});

  @override
  State<AddEditText> createState() => _AddEditTextState();
}

class _AddEditTextState extends State<AddEditText> {
  late final TextEditingController controller;

  String? errorText;

  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.text ?? "");
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  String? _getValue() {
    final value = controller.text.trim();

    if (value.isEmpty) {
      setState(() {
        errorText = "Please enter a value";
      });
      return null;
    }

    setState(() {
      errorText = null;
    });

    return value;
  }

  void _save() {
    final value = _getValue();

    if (value == null) return;

    Navigator.pop(
      context,
      AddEditTextResult(value: value, action: AddEditTextAction.save),
    );
  }

  void _next() {
    final value = _getValue();

    if (value == null) return;

    Navigator.pop(
      context,
      AddEditTextResult(value: value, action: AddEditTextAction.next),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.isEdit ? "Edit" : "Add";

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(title, style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CTextFormField(
                controller: controller,
                label: "",
                autofocus: true,
                focusNode: focusNode,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Visibility(
                visible: errorText != null,
                child: Text(
                  errorText ?? "",
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: .end,
              children: [
                if (!widget.isEdit) ...[
                  TextButton(onPressed: _next, child: const Text("Next")),
                  Spacer(),
                ],

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                TextButton(onPressed: _save, child: const Text("Save")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddButtonRow extends StatelessWidget {
  const AddButtonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: const Row(
        mainAxisSize: .min,
        children: [
          Icon(Icons.add_circle),
          SizedBox(width: 10),
          Text("Add Item"),
        ],
      ),
    );
  }
}

class CheckList extends StatefulWidget {
  final List<CheckNote> list;
  final bool isEditing;
  final FocusNode titleFocusNode;
  const CheckList({
    super.key,
    required this.list,
    required this.isEditing,
    required this.titleFocusNode,
  });

  @override
  State<CheckList> createState() => _CheckListState();
}

class _CheckListState extends State<CheckList> {
  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        // Button to add note at first
        if (!widget.isEditing)
          InkWell(
            onTap: () async {
              await addItemInList(insertFirst: true);
            },
            child: const AddButtonRow(),
          ),

        if (widget.list.isEmpty && !widget.isEditing) const Divider(),

        // list of added notes
        if (widget.list.isEmpty)
          SizedBox.shrink()
        else
          Container(
            decoration: BoxDecoration(
              border: Border.fromBorderSide(
                BorderSide(
                  width: 2,
                  color: isDark ? AppColors.primary : AppColors.dThirdColor,
                ),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: widget.isEditing
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.list.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final cn = widget.list[index];

                      return listTile(cn: cn, index: index);
                    },
                  )
                : ReorderableListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.list.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final cn = widget.list[index];

                      return listTile(cn: cn, index: index);
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }

                        final item = widget.list.removeAt(oldIndex);
                        widget.list.insert(newIndex, item);
                      });
                    },
                  ),
          ),

        // Button to add note at last
        if (!widget.isEditing)
          InkWell(
            onTap: () async {
              await addItemInList(insertFirst: false);
            },
            child: const AddButtonRow(),
          ),
      ],
    );
  }

  Widget listTile({required CheckNote cn, required int index}) {
    return Stack(
      key: ValueKey("${index}_${cn.title}"),
      children: [
        Column(
          mainAxisSize: .min,
          children: [
            if (index != 0) Divider(height: 0.1, thickness: 0.2),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 5),
              onTap: !widget.isEditing
                  ? () async {
                      // Show dialog to edit single note from list
                      final AddEditTextResult? result =
                          await showDialog<AddEditTextResult>(
                            context: context,
                            builder: (dContext) {
                              return AddEditText(isEdit: true, text: cn.title);
                            },
                          );

                      // Cancel / dismiss
                      if (result == null) return;

                      logger.d("value: ${result.value}");

                      final int objectIndex = index;
                      widget.list.removeAt(objectIndex);

                      setState(() {
                        widget.list.insert(
                          objectIndex,
                          CheckNote(title: result.value, isEnabled: true),
                        );
                      });
                    }
                  : () {
                      setState(() {
                        if (cn.isEnabled) {
                          // If enabled then disable it
                          cn.isEnabled = false;
                        } else {
                          // If disabled then enable it
                          cn.isEnabled = true;
                        }
                      });
                    },
              leading: !widget.isEditing
                  ? ReorderableDelayedDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle_rounded),
                    )
                  : null,
              title: Text(
                cn.title,
                style: cn.isEnabled
                    ? null
                    : TextStyle(
                        decoration: .lineThrough,
                        decorationThickness: 2,
                        decorationStyle: .solid,
                        color: Colors.blueGrey.shade400,
                        decorationColor: Colors.blueGrey.shade400,
                      ),
              ),
              trailing: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .end,
                children: [
                  if (!cn.isEnabled && widget.isEditing)
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(Icons.done, color: Colors.blueGrey.shade300),
                    )
                  else if (!widget.isEditing)
                    IconButton(
                      visualDensity: .compact,
                      onPressed: () {
                        setState(() {
                          widget.list.removeAt(index);
                        });
                        logger.d("Deleted item: ${cn.title}");
                      },
                      icon: Icon(Icons.cancel, color: Colors.red),
                    )
                  else
                    PopupMenuButton(
                      iconColor: Colors.blueGrey.shade300,
                      menuPadding: EdgeInsets.zero,
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(text: cn.title),
                              );

                              scaffoldMessenger('Copied to clipboard');

                              logger.d("Copied item: ${cn.title}");
                            },
                            child: Text("Copy to Clipboard"),
                          ),

                          PopupMenuItem(
                            onTap: () {
                              setState(() {
                                widget.list.removeAt(index);
                              });
                              logger.d("Deleted item: ${cn.title}");
                            },
                            child: Text("Delete"),
                          ),
                        ];
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> addItemInList({required bool insertFirst}) async {
    if (widget.titleFocusNode.hasFocus) widget.titleFocusNode.nextFocus();

    while (true) {
      final AddEditTextResult? result = await showDialog<AddEditTextResult>(
        context: context,
        builder: (dialogContext) {
          return const AddEditText(isEdit: false);
        },
      );

      // Cancel / dismiss
      if (result == null) break;

      logger.d(
        "${result.action == AddEditTextAction.next ? 'Next' : 'Saved'} "
        "value: ${result.value}",
      );

      final cn = CheckNote(title: result.value, isEnabled: true);

      setState(() {
        if (insertFirst) {
          widget.list.insert(0, cn);
        } else {
          widget.list.insert(widget.list.length, cn);
        }
      });

      // Save = finish adding items
      if (result.action == AddEditTextAction.save) {
        break;
      }

      // Next = loop and show the dialog again
    }
  }
}

// Stateless Widgets
class ReminderCard extends StatelessWidget {
  final String text;
  final IconData icon;
  const ReminderCard({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(10),
      ),
      margin: EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          mainAxisAlignment: .center,
          children: [Icon(icon), const SizedBox(width: 6), Text(text)],
        ),
      ),
    );
  }
}

class NotePopupMenu extends StatelessWidget {
  final bool isProtected;
  final VoidCallback shareCB, reminderCB, deleteCB;
  final VoidCallback lockCB;

  const NotePopupMenu({
    super.key,
    required this.isProtected,
    required this.shareCB,
    required this.reminderCB,
    required this.deleteCB,
    required this.lockCB,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      menuPadding: EdgeInsets.zero,
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            onTap: shareCB,
            child: const Row(
              children: [Icon(Icons.share), SizedBox(width: 5), Text("Share")],
            ),
          ),
          PopupMenuItem(
            onTap: reminderCB,
            child: const Row(
              children: [
                Icon(Icons.notifications_outlined),
                SizedBox(width: 5),
                Text("Reminder"),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: deleteCB,
            child: const Row(
              children: [
                Icon(Icons.delete_outline),
                SizedBox(width: 5),
                Text("Delete"),
              ],
            ),
          ),
          if (!isProtected)
            PopupMenuItem(
              onTap: lockCB,
              child: const Row(
                children: [
                  Icon(Icons.security_outlined),
                  SizedBox(width: 5),
                  Text("Lock"),
                ],
              ),
            ),
        ];
      },
    );
  }
}

class ReminderCancelDialog extends StatelessWidget {
  const ReminderCancelDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Alert"),
      content: Text(
        "Are you sure you want to lock this note?\nLocking this note will cancel its reminders.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Proceed", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

class ReminderIcon extends StatelessWidget {
  final bool position;
  const ReminderIcon({super.key, this.position = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return position
        ? getContainer(isDark, position)
        : Positioned(top: 8, right: 8, child: getContainer(isDark, position));
  }

  Container getContainer(bool isDark, bool position) {
    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primary : AppColors.dSecondColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(Icons.alarm, size: position ? 20 : 15, color: Colors.white),
      ),
    );
  }
}

class OptionDialog extends StatelessWidget {
  final String titleText;
  final VoidCallback onTapOption1;
  final VoidCallback onTapOption2;
  final String option1Text;
  final String option2Text;
  const OptionDialog({
    super.key,
    required this.titleText,
    required this.onTapOption1,
    required this.onTapOption2,
    required this.option1Text,
    required this.option2Text,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titleText, textAlign: TextAlign.center),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(onPressed: onTapOption1, child: Text(option1Text)),
          OutlinedButton(onPressed: onTapOption2, child: Text(option2Text)),
        ],
      ),
    );
  }
}

class PinnedCard extends StatelessWidget {
  final NotificationService notificationService;
  final Note? eNote;
  const PinnedCard({
    super.key,
    required this.notificationService,
    required this.eNote,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: notificationService.isTaskPinned(eNote!.uid),
      builder: (context, snapshot) {
        // Handle the loading/waiting state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        }

        // Extract the boolean result (default to false if null)
        final isPinned = snapshot.data ?? false;

        // Return UI based on the pinned state
        return isPinned
            ? ReminderCard(icon: Icons.push_pin_outlined, text: "Pinned")
            : const SizedBox.shrink();
      },
    );
  }
}

class ScheduledCard extends StatelessWidget {
  final NotificationService notificationService;
  final Note? eNote;
  const ScheduledCard({
    super.key,
    required this.notificationService,
    required this.eNote,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: notificationService.getScheduledDate(eNote!.uid),
      builder: (context, snapshot) {
        // Handle the loading/waiting state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        }

        // Extract the boolean result (default to false if null)
        final scheduledDT = snapshot.data;

        final isScheduled = scheduledDT != null;

        // Return UI based on the pinned state
        return isScheduled
            ? Column(
                children: [
                  SizedBox(height: 10),
                  ReminderCard(
                    // .toLocal() ensures it displays in the user's timezone
                    text:
                        "Reminder: ${DateFormat("dd/MM/yyyy hh:mm a").format(DateTime.parse(scheduledDT).toLocal())}",
                    icon: Icons.alarm_on,
                  ),
                ],
              )
            : const SizedBox.shrink();
      },
    );
  }
}

class TitleField extends StatelessWidget {
  final bool isEditing;
  final TextEditingController cTitle;
  final FocusNode titleFocusNode;
  const TitleField({
    super.key,
    required this.isEditing,
    required this.cTitle,
    required this.titleFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        CLabel(text: "Title"),
        CTextFormField(
          controller: cTitle,
          label: "Title",
          focusNode: titleFocusNode,
          readOnly: isEditing,
          inputFormatters: [FilteringTextInputFormatter.allow(titlePattern)],
        ),
      ],
    );
  }
}

class DisplayContent extends StatelessWidget {
  final Note note;
  final bool isVertical;

  const DisplayContent({super.key, required this.note, this.isVertical = true});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    List<CheckNote> list = [];
    final ScrollController scrollController = ScrollController();

    String content = note.content;
    if (note.isCheckList) {
      list = NoteFunctions.convertContentToList(content) ?? [];
    }

    return Expanded(
      child: note.isCheckList
          ? isVertical
                ? Scrollbar(
                    thickness: 1,
                    controller: scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: .min,
                          crossAxisAlignment: .start,
                          children: list.map((item) {
                            return contentText(
                              textTheme,
                              item.title,
                              note.isCheckList,
                              item.isEnabled,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: .min,
                    children: [
                      ...list.take(1).map((item) {
                        return Expanded(
                          child: contentText(
                            textTheme,
                            item.title,
                            note.isCheckList,
                            item.isEnabled,
                          ),
                        );
                      }),
                      const SizedBox(width: 15),
                    ],
                  )
          : contentText(textTheme, content, note.isCheckList, true),
    );
  }

  Widget contentText(
    TextTheme textTheme,
    String content,
    bool isCheckList,
    bool isEnabled,
  ) {
    final textColor = textTheme.bodySmall?.color;
    return Text(
      isCheckList ? "-${isVertical ? content : "$content "}" : content,
      style: isCheckList
          ? textTheme.bodySmall?.copyWith(
              color: textColor?.withValues(alpha: isEnabled ? 0.75 : 0.4),
              decoration: isEnabled ? null : .lineThrough,
              decorationColor: textColor?.withValues(alpha: 0.6),
            )
          : textTheme.bodySmall?.copyWith(
              color: textTheme.bodySmall?.color?.withValues(alpha: 0.75),
            ),
      maxLines: isCheckList ? 1 : 5,
      overflow: .ellipsis,
    );
  }
}
