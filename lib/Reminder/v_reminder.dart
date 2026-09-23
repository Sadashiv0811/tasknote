import 'package:flutter/material.dart';
import 'package:tasknote/Note/common.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Reminder/Model/m_reminder.dart';
import 'package:tasknote/Service/s_notification.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/Note/note_functions.dart';
import 'package:tasknote/Other_Views/v_splash.dart';

enum EnumReminder { pinned, scheduled, cancel, closed }

class VReminder extends StatefulWidget {
  final Note note;
  const VReminder({super.key, required this.note});

  @override
  State<VReminder> createState() => _VReminderState();
}

class _VReminderState extends State<VReminder> {
  final NotificationService notificationService = NotificationService();
  bool isPinned = false, isScheduled = false;

  Future<void> _pickDateAndTimeAndSchedule() async {
    // Pick Date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    // Pick Time
    if (!mounted) return;
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    // Combine
    final DateTime scheduledDT = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final reminder = buildReminder(isPin: false, scheduledDT: scheduledDT);

    final bool result = await notificationService.scheduleTaskReminder(
      reminder,
    );

    if (result) {
      await reminderController.addReminderInDB(reminder: reminder);

      if (!mounted) return;
      logger.d("Reminder set for $scheduledDT");
      Navigator.pop(context, EnumReminder.scheduled.name);
    }
  }

  Future<void> _handlePinTask() async {
    final reminder = buildReminder(isPin: true, scheduledDT: null);

    await reminderController.addReminderInDB(reminder: reminder);

    await notificationService.pinTaskToStatusBar(reminder);

    if (!mounted) return;
    logger.d("Note pinned to status bar!");
    Navigator.pop(context, EnumReminder.pinned.name);
  }

  Reminder buildReminder({
    required bool isPin,
    required DateTime? scheduledDT,
  }) {
    String content = widget.note.content;
    String formattedContent = content;
    List<CheckNote> list = [];

    if (widget.note.isCheckList) {
      list = NoteFunctions.convertContentToList(content) ?? [];
      formattedContent = NoteFunctions.getFormattedContent(list);
    }

    return Reminder(
      title: widget.note.title,
      content: formattedContent,
      noteUID: widget.note.uid,
      isActive: true,
      isPinned: isPin,
      scheduledDT: scheduledDT,
    );
  }

  @override
  void initState() {
    super.initState();
    initializeValues();
  }

  void initializeValues() async {
    final reminder = await reminderController.getReminderByNoteUid(
      widget.note.uid,
    );

    if (reminder != null && reminder.isPinned) {
      isPinned = true;
    }
    if (reminder != null && reminder.isPinned == false) {
      isScheduled = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;
    final textColor = textTheme.bodySmall?.color;

    String content = widget.note.content;
    List<CheckNote> list = [];
    final bool isCheckList = widget.note.isCheckList;
    if (isCheckList) {
      list = NoteFunctions.convertContentToList(content) ?? [];
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: isDark ? AppColors.dThirdColor : AppColors.lThirdColor,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab/Drag Handle for Bottom Sheet
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header Section
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Reminder Type",
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context, EnumReminder.closed.name);
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: isDark
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Divider(
                thickness: 1.0,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 16),

              // Note Preview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TITLE",
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      widget.note.title,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "CONTENT",
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (!isCheckList)
                      Text(
                        content,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      )
                    else if (isCheckList && list.isNotEmpty)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: getHeight(context, 0.1),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: .start,
                            children: list.map((item) {
                              return Text(
                                "- ${item.title}",
                                style: textTheme.bodySmall?.copyWith(
                                  color: textColor?.withValues(
                                    alpha: item.isEnabled ? 0.75 : 0.4,
                                  ),
                                  fontSize: 14,
                                  decoration: item.isEnabled
                                      ? null
                                      : .lineThrough,
                                  decorationColor: textColor?.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: .ellipsis,
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    else
                      Text("-"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Pin
              Visibility(
                visible: !isScheduled,
                child: _CustomButton(
                  reminderType: "Pin",
                  status: isPinned,
                  onTap: () async {
                    // Cancel/Delete
                    if (isPinned) {
                      // Cancel notification
                      await notificationService.cancelPinnedTask(
                        widget.note.uid,
                      );

                      // Delete object
                      await reminderController.deleteReminderByNoteUID(
                        widget.note.uid,
                      );

                      logger.d(
                        "Cancelled pinned notification and deleted reminder object",
                      );

                      if (!context.mounted) return;
                      Navigator.pop(context, EnumReminder.cancel.name);
                    }
                    // Add
                    else {
                      await _handlePinTask();
                    }
                    // Force a rebuild to refresh the FutureBuilder state
                    setState(() {});
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Schedule
              Visibility(
                visible: !isPinned,
                child: _CustomButton(
                  reminderType: "Schedule",
                  status: isScheduled,
                  onTap: () async {
                    // Cancel/Delete
                    if (isScheduled) {
                      // Cancel notification
                      await notificationService.cancelScheduledTask(
                        widget.note.uid,
                      );

                      // Delete object
                      await reminderController.deleteReminderByNoteUID(
                        widget.note.uid,
                      );

                      logger.d(
                        "Cancelled scheduled notification and deleted reminder object",
                      );

                      if (!context.mounted) return;
                      Navigator.pop(context, EnumReminder.cancel.name);
                    }
                    // Add
                    else {
                      await _pickDateAndTimeAndSchedule();
                    }
                    // Force a rebuild to refresh the FutureBuilder state
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Stateless Widgets
class _CustomButton extends StatelessWidget {
  final bool status;
  final String reminderType;
  final VoidCallback onTap;

  const _CustomButton({
    required this.status,
    required this.reminderType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String buttonText = "Set Reminder";
    IconData buttonIcon = Icons.alarm_on;

    if (reminderType == "Pin") {
      buttonText = status ? "Clear Pin" : "Pin Note";
      buttonIcon = status ? Icons.push_pin : Icons.push_pin_outlined;
    } else {
      buttonText = status ? "Cancel Reminder" : "Schedule Reminder";
      buttonIcon = status ? Icons.alarm_off : Icons.alarm_on;
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        label: Text(
          buttonText,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        icon: Icon(buttonIcon, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: status
              ? Colors.redAccent.shade400
              : Colors.white.withValues(alpha: 0.12),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: status
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
