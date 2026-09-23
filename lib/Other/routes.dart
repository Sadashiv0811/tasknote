import 'package:flutter/material.dart';
import 'package:tasknote/Note/Views/ae_checklist_note.dart';
import 'package:tasknote/Group/Views/ae_group.dart';
import 'package:tasknote/Note/Views/ae_note.dart';
import 'package:tasknote/Note/common.dart';
import 'package:tasknote/User/v_auth.dart';
import 'package:tasknote/Other_Views/v_home.dart';
import 'package:tasknote/Share/v_pdf_preview.dart';
import 'package:tasknote/Note/Protected/v_protected_notes.dart';

class Routes {
  static const _duration = Duration(milliseconds: 500);
  static const String home = '/home';
  static const String auth = '/auth';
  static const String addEditNote = '/ae_note';
  static const String addEditGroup = '/ae_group';
  static const String protectedNotes = '/protectedNotes';
  static const String pdfPreview = '/pdfPreview';
  static const String addEditCheckListNote = '/ae_check_note';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _slideRoute(const VHome());

      case auth:
        return _slideRoute(const VAuth());

      case protectedNotes:
        return _slideRoute(VProtectedNotes());

      case pdfPreview:
        // Safely extract and cast the incoming map arguments
        final args = settings.arguments as Map<String, String>? ?? {};

        // Extract specific keys with safe fallback defaults
        final initialText = args['initialText'] ?? '';
        final fileName = args['fileName'] ?? 'Untitled Note';

        // Pass them cleanly into your page widget
        return _slideRoute(
          VPdfPreviewPage(initialText: initialText, fileName: fileName),
        );

      case addEditNote:
        final args = settings.arguments as AddEditNoteArgs?;
        // This retrieves whatever data sent using the arguments: parameter.

        if (args == null) {
          throw Exception('AddEditNoteArgs is required');
        }

        return _slideRoute(
          AddEditNote(
            edit: args.edit,
            eNote: args.eNote,
            calNote: args.calNote,
            selected: args.selected,
            groupNote: args.groupNote,
            groupId: args.groupId,
          ),
        );

      case addEditGroup:
        final args = settings.arguments as AddEditGroupArgs?;

        if (args == null) {
          throw Exception('AddEditGroupArgs is required');
        }

        return _slideRoute(
          AddEditGroup(
            edit: args.edit,
            eGroup: args.eGroup,
            selectedNoteUidList: args.selectedNoteUidList,
          ),
        );

      case addEditCheckListNote:
        final args = settings.arguments as AddEditNoteArgs?;

        if (args == null) {
          throw Exception('AddEditNoteArgs is required');
        }

        return _slideRoute(
          AddEditCheckListNote(
            edit: args.edit,
            eNote: args.eNote,
            calNote: args.calNote,
            selected: args.selected,
            groupNote: args.groupNote,
            groupId: args.groupId,
          ),
        );

      default:
        return _slideRoute(const VHome());
    }
  }

  /// Smooth slide from right → left
  static Route<dynamic> _slideRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;

        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: end,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
}
