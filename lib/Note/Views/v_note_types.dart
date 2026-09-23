import 'package:flutter/material.dart';

enum NoteType { text, checklist }

Future<NoteType?> showNoteTypeDialog(BuildContext context) {
  return showDialog<NoteType>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Choose Note Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NoteTypeOption(
              icon: Icons.text_fields,
              title: 'Text',
              onTap: () => Navigator.pop(context, NoteType.text),
            ),
            const SizedBox(height: 12),
            _NoteTypeOption(
              icon: Icons.check_box_outlined,
              title: 'Checklist',
              onTap: () => Navigator.pop(context, NoteType.checklist),
            ),
          ],
        ),
      );
    },
  );
}

class _NoteTypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _NoteTypeOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
