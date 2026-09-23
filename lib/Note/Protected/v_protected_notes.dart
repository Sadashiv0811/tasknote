import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tasknote/Note/common.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/Note/Protected/edit_protected_note.dart';
import 'package:tasknote/Other_Views/v_splash.dart';
import 'package:tasknote/Service/s_note_security.dart';

class VProtectedNotes extends StatefulWidget {
  const VProtectedNotes({super.key});

  @override
  State<VProtectedNotes> createState() => _VProtectedNotesState();
}

class _VProtectedNotesState extends State<VProtectedNotes> {
  final Set<int> _selectedNoteIds = {};
  bool _isSelectionMode = false;

  late Stream<List<Note>> _notesStream;

  final NoteSecurityService _securityService = NoteSecurityService.instance;

  void _toggleSelection(int noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);

        if (_selectedNoteIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedNoteIds.add(noteId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNoteIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _handleUnprotect(List<Note> allNotes) async {
    final notesToUnprotect = allNotes
        .where((note) => _selectedNoteIds.contains(note.id))
        .toList();

    if (notesToUnprotect.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _UnprotectConfirmationDialog(count: notesToUnprotect.length),
    );

    if (confirm != true) return;

    // Get Master Key from the security service.
    final masterKey = _securityService.masterKey;

    if (masterKey == null) {
      if (!mounted) return;

      scaffoldMessenger("Security session expired. Please unlock again.");

      return;
    }

    final success = await noteController.unprotectNotes(
      notesToUnprotect,
      masterKey,
    );

    if (success) {
      _clearSelection();

      if (!mounted) return;

      scaffoldMessenger("Notes removed successfully.");
    } else {
      if (!mounted) return;

      scaffoldMessenger("Failed to remove notes.");
    }
  }

  Future<void> _saveEditedNote(Note editedNote, Note currentNote) async {
    final isar = userController.isar;

    // Get the Master Key.
    final masterKey = _securityService.masterKey;

    if (masterKey == null) {
      if (!mounted) return;

      scaffoldMessenger("Security session expired. Please unlock again.");

      return;
    }

    try {
      // Encrypt using the Master Key.
      final encryptedTitle = _securityService.encryptText(
        editedNote.title,
        masterKey,
      );

      final encryptedContent = _securityService.encryptText(
        editedNote.content,
        masterKey,
      );

      await isar.writeTxn(() async {
        // Fetch the original encrypted note.
        final dbNote = await isar.notes.get(editedNote.id);

        if (dbNote != null) {
          dbNote.title = encryptedTitle;
          dbNote.content = encryptedContent;
          dbNote.decorColor = editedNote.decorColor;
          dbNote.updatedAt = editedNote.updatedAt;

          await isar.notes.put(dbNote);
        }
      });

      logger.d("Note updated securely.");
    } catch (e, stackTrace) {
      logger.e("Error saving encrypted note", error: e, stackTrace: stackTrace);

      if (!mounted) return;

      scaffoldMessenger("Failed to save changes securely.");
    }
  }

  @override
  void initState() {
    super.initState();

    // Master Key must have been created by NoteAuth before this screen is opened.
    final masterKey = _securityService.masterKey;

    if (masterKey == null) {
      _notesStream = Stream.error(Exception("Master key is not available"));

      return;
    }

    _notesStream = noteController.listenToProtectedNoteSchema(masterKey);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<List<Note>>(
      stream: _notesStream,
      builder: (context, snapshot) {
        final protectedNotes = snapshot.data ?? [];

        // Dynamic App Bar behavior based on active Selection Mode
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isSelectionMode
                  ? "Selected: ${_selectedNoteIds.length}"
                  : "Protected Notes",
            ),
            leading: _isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearSelection,
                  )
                : null,
            actions: [
              if (_isSelectionMode)
                IconButton(
                  icon: const Icon(Icons.lock_open_outlined),
                  onPressed: () => _handleUnprotect(protectedNotes),
                ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
            ),
            child: SafeArea(
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : protectedNotes.isEmpty
                  ? Center(
                      child: Text(
                        "No protected notes found.",
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: protectedNotes.length,
                        itemBuilder: (context, index) {
                          final note = protectedNotes[index];
                          final isSelected = _selectedNoteIds.contains(note.id);

                          return _ProtectedNoteCard(
                            note: note,
                            isSelected: isSelected,
                            isSelectionMode: _isSelectionMode,
                            onTap: () async {
                              if (_isSelectionMode) {
                                _toggleSelection(note.id);
                              } else {
                                // Navigate to the edit screen and wait for the edited note back
                                final Note? updatedNote =
                                    await Navigator.push<Note>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditProtectedNote(note: note),
                                      ),
                                    );

                                // If a note was returned, handle the re-encryption and database save
                                if (updatedNote != null) {
                                  await _saveEditedNote(updatedNote, note);
                                }
                              }
                            },
                            onLongPress: () {
                              if (!_isSelectionMode) {
                                setState(() {
                                  _isSelectionMode = true;
                                  _selectedNoteIds.add(note.id);
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

// Stateless Widgets
class _ProtectedNoteCard extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ProtectedNoteCard({
    required this.note,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color baseColor = note.color;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? baseColor.withValues(alpha: 0.2)
                  : (isDarkMode
                        ? baseColor.withValues(alpha: 0.3)
                        : baseColor.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : baseColor.withValues(alpha: isDarkMode ? 0.4 : 0.25),
                width: isSelected ? 2.0 : 1.5,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.grouped)
                      Icon(
                        Icons.folder_outlined,
                        size: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                  ],
                ),

                DisplayContent(note: note),

                Divider(
                  height: 16,
                  color: textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}",
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: textTheme.bodySmall?.color?.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.enhanced_encryption_rounded,
                      size: 14,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isSelectionMode)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : baseColor.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class _UnprotectConfirmationDialog extends StatelessWidget {
  final int count;

  const _UnprotectConfirmationDialog({required this.count});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Unprotect Notes"),
      content: Text(
        "Are you sure you want to remove $count selected note(s) from protected notes?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Remove", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

class ShowRecoveryKeyDialog extends StatelessWidget {
  final String recoveryKey;

  const ShowRecoveryKeyDialog({super.key, required this.recoveryKey});

  Future<void> _copyRecoveryKey(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: recoveryKey));

    if (!context.mounted) return;

    scaffoldMessenger("Recovery key copied.");
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      title: const CDialogTitle(text: "Save Your Recovery Key"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CDialogContent(
            text1:
                "This recovery key is the only way to reset your password if you forget it.",
          ),

          const SizedBox(height: 20),

          Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isDark ? AppColors.lSecondColor : AppColors.dSecondColor,
            ),
            child: SelectableText(
              recoveryKey,
              selectionColor: isDark
                  ? AppColors.dSecondColor
                  : AppColors.lSecondColor,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () => _copyRecoveryKey(context),
            icon: const Icon(Icons.copy),
            label: const Text("Copy Recovery Key"),
          ),

          const SizedBox(height: 16),

          const Text(
            "Store this key somewhere safe. It will not be shown again.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text("I've Saved It"),
        ),
      ],
    );
  }
}
