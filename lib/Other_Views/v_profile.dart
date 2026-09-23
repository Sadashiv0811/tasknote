import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:tasknote/Note/note_functions.dart';
import 'package:tasknote/Service/s_notification.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Other/routes.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/User/Model/m_user.dart';
import 'package:tasknote/Service/s_authentication.dart';
import 'package:tasknote/Service/s_backup.dart';
import 'package:tasknote/Service/s_clear_data.dart';
import 'package:tasknote/Service/s_import.dart';
import 'package:tasknote/Service/s_shared_pref.dart';
import 'package:tasknote/Other_Views/v_splash.dart';
import 'package:tasknote/Note/Protected/v_note_auth.dart';

class VProfile extends StatefulWidget {
  const VProfile({super.key});

  @override
  State<VProfile> createState() => _VProfileState();
}

class _VProfileState extends State<VProfile> {
  final NotificationService notificationService = NotificationService();

  int totalNotes = 0;
  int totalGroups = 0;

  MUser? user;
  bool loggedIn = false;
  bool isloggingOut = false;
  String email = "";
  String fullName = "";

  @override
  void initState() {
    super.initState();
    getUser();
    getTotalCount();
  }

  Future<void> getUser() async {
    bool isConnected = await checkInternet();

    // Online
    if (isConnected) {
      // Get the current Firebase Auth user session
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        // Fetch the corresponding custom MUser from Isar using the UID
        final MUser? localUser = await userController.fetchByUid(
          firebaseUser.uid,
        );

        if (!mounted) return;
        setState(() {
          loggedIn = true;
          user = localUser;
          email = localUser?.email ?? firebaseUser.email ?? "";
          fullName = localUser?.fullName ?? firebaseUser.displayName ?? "";
        });
      } else {
        if (!mounted) return;
        setState(() {
          loggedIn = false;
          email = "";
          fullName = ""; // Reset fullName on null session
          user = null;
        });
      }
    }
    // Offline
    else {
      // Offline Fallback: Read the user profile directly from local Isar cache
      final localUser = await userController.isar.mUsers
          .where()
          .build()
          .findFirst();

      if (!mounted) return;
      setState(() {
        loggedIn = localUser != null;
        user = localUser;
        email = localUser?.email ?? "";
        fullName = localUser?.fullName ?? "";
      });
    }
  }

  void getTotalCount() async {
    final [noteResult, groupResult] = await Future.wait([
      noteController.getTotalNoteCount(),
      groupController.getTotalGroupCount(),
    ]);

    if (!mounted) return;
    setState(() {
      totalGroups = groupResult;
      totalNotes = noteResult;
    });
  }

  // Switch From light to dark mode and vice versa
  static void toggleTheme() {
    if (themeNotifier.value == ThemeMode.light) {
      themeNotifier.value = ThemeMode.dark;
      SharedPrefService.saveMode("dark");
    } else {
      themeNotifier.value = ThemeMode.light;
      SharedPrefService.saveMode("light");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedTheme(
        data: theme,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: isDark
                          ? AppColors.lThirdColor
                          : AppColors.dFirstColor,
                      child: loggedIn && fullName.trim().isNotEmpty
                          ? Text(
                              fullName.trim()[0].toUpperCase(),
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontFamily: 'inter',
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loggedIn ? email : 'Guest User',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'inter',
                      ),
                    ),
                    if (loggedIn) ...[
                      const SizedBox(height: 6),
                      Text(
                        // If logged in but name hasn't arrived yet, show a clean placeholder instead of an empty gap
                        loggedIn
                            ? (fullName.trim().isNotEmpty
                                  ? fullName
                                  : 'Loading...')
                            : '',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'inter',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Statistics Section
              _SectionGroup(
                title: "Overview",
                theme: theme,
                isDark: isDark,
                children: [
                  _CMenuItem(
                    context: context,
                    icon: Icons.notes,
                    title: "Total Notes",
                    tWidget: Text(
                      totalNotes.toString(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter',
                      ),
                    ),
                  ),
                  _CDivider(theme: theme),
                  _CMenuItem(
                    context: context,
                    icon: Icons.folder,
                    title: "Total Folders",
                    tWidget: Text(
                      totalGroups.toString(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // App Preferences
              _SectionGroup(
                title: "Preferences",
                theme: theme,
                isDark: isDark,
                children: [
                  _CMenuItem(
                    context: context,
                    icon: isDark ? Icons.dark_mode : Icons.light_mode,
                    title: "Dark Mode",
                    tWidget: Switch.adaptive(
                      splashRadius: 5.0,
                      inactiveTrackColor: AppColors.lThirdColor,
                      inactiveThumbColor: Colors.white,
                      value: isDark,
                      onChanged: (value) {
                        toggleTheme();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Features Section
              _SectionGroup(
                title: "Features",
                theme: theme,
                isDark: isDark,
                children: [
                  _CMenuItem(
                    context: context,
                    icon: Icons.lock_rounded,
                    title: "Password Protected Notes",
                    onTap: () async {
                      if (!loggedIn || user?.uid == null) {
                        if (!context.mounted) return;

                        scaffoldMessenger(
                          "Log in to access password-protected notes.",
                        );
                        return;
                      }

                      final encryptedMasterKey = user!.encryptedMasterKey;

                      // First-time setup
                      if (encryptedMasterKey == null ||
                          encryptedMasterKey.trim().isEmpty) {
                        await setupNoteSecurity(context, user!);
                        return;
                      }

                      // Existing password
                      await authenticateNoteSecurity(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Data Management & Sync
              _SectionGroup(
                title: "Data & Storage",
                theme: theme,
                isDark: isDark,
                children: [
                  _CMenuItem(
                    context: context,
                    icon: Icons.cloud_upload,
                    title: "Backup to Cloud",
                    onTap: () async {
                      await backupProcess();
                    },
                  ),
                  _CDivider(theme: theme),

                  _CMenuItem(
                    context: context,
                    icon: Icons.cloud_download,
                    title: "Import from Cloud",
                    onTap: () async {
                      // Login and Internet check
                      final bool check = await checkInternetAndUser();
                      if (!check) return;

                      await importProcess();
                    },
                  ),
                  _CDivider(theme: theme),

                  _CMenuItem(
                    context: context,
                    icon: Icons.delete_sweep,
                    title: "Clear Local Data",
                    onTap: () async {
                      await clearLocalData();
                    },
                  ),
                  _CDivider(theme: theme),

                  _CMenuItem(
                    context: context,
                    icon: Icons.delete_forever,
                    title: "Clear All Data",
                    onTap: () async {
                      await clearAllData();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Login / Logout Button
              Align(
                alignment: Alignment.center,
                child: loggedIn
                    ?
                      // Logout
                      _LogInOutButton(
                        isLogin: false,
                        onPressed: () async {
                          await logoutProcess();
                        },
                      )
                    :
                      // Login
                      _LogInOutButton(
                        isLogin: true,
                        onPressed: () async {
                          final authResult = await Navigator.pushNamed(
                            context,
                            Routes.auth,
                          );

                          if (authResult == null) return;

                          bool isConnected = await checkInternet();

                          if (!context.mounted) return;

                          if (!isConnected) {
                            scaffoldMessenger("No internet connection");
                            return;
                          }

                          await getUser();
                          if (!context.mounted) return;
                          if (user == null || authResult == "signup") return;

                          // Check if data exists on cloud
                          // Check both collections concurrently
                          final [
                            noteResults,
                            groupResults,
                          ] = await Future.wait([
                            ImportService.checkNotesInFirebase(
                              userId: user!.uid.toString(),
                            ),
                            ImportService.checkGroupsInFirebase(
                              userId: user!.uid.toString(),
                            ),
                          ]);

                          if (!noteResults.isSnapEmpty ||
                              !groupResults.isSnapEmpty) {
                            await importProcess();
                          }
                        },
                      ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> setupNoteSecurity(BuildContext context, MUser user) async {
    final masterKey = await NoteFunctions.setupNoteSecurity(
      context: context,
      user: user,
    );

    if (masterKey == null) {
      return;
    }

    if (!context.mounted) return;

    Navigator.pushNamed(context, Routes.protectedNotes);
  }

  Future<void> authenticateNoteSecurity(BuildContext context) async {
    final bool? authenticated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const NoteAuth(),
    );

    if (authenticated != true) {
      return;
    }

    if (!context.mounted) return;

    Navigator.pushNamed(context, Routes.protectedNotes);
  }

  Future<bool> checkInternetAndUser() async {
    // Login Check
    if (!loggedIn || user == null || user?.uid == null) {
      if (mounted) scaffoldMessenger("Login to proceed");
      return false;
    }

    // Internet Check
    bool isConnected = await checkInternet();

    if (!isConnected) {
      if (mounted) scaffoldMessenger("No internet connection");
      return false;
    }

    return true;
  }

  Future<void> logoutProcess() async {
    // Login and Internet check
    final bool check = await checkInternetAndUser();
    if (!check) return;

    if (!mounted) return;

    final bool? result = await showDialog(
      context: context,
      builder: (context) =>
          _LogoutDialog(notificationService: notificationService),
    );

    if (result != null && result == true) {
      loggedIn = false;
      getTotalCount();

      scaffoldMessenger("Logged Out");
    }
  }

  Future<void> clearLocalData() async {
    final bool? result = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _ClearDataDialog(
          localOnly: true,
          positiveBtnText: "Clear",
          negativeBtnText: "Cancel",
        );
      },
    );

    if (!mounted || result == null) return;

    if (result) {
      await notificationService.cancelAll();
      getTotalCount();
    }
  }

  Future<void> backupProcess() async {
    // Login and Internet check
    final bool check = await checkInternetAndUser();
    if (!check || !mounted) return;

    await showDialog(
      context: context,
      builder: (context) => _BackupDialog(user: user!),
    );
  }

  Future<void> importProcess() async {
    final bool? dialogResult = await showDialog(
      context: context,
      builder: (context) => _ImportDialog(user: user!),
    );

    if (!mounted || dialogResult == null) return;

    if (dialogResult) {
      getTotalCount();
    }
  }

  Future<void> clearAllData() async {
    // Login and Internet check
    final bool check = await checkInternetAndUser();
    if (!check || !mounted) return;

    final bool? result = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _ClearDataDialog(
          localOnly: false,
          positiveBtnText: "Wipe Everything",
          negativeBtnText: "Cancel",
        );
      },
    );

    if (!mounted || result == null) return;

    if (result) {
      await notificationService.cancelAll();
      getTotalCount();
    }
  }
}

// Stateful Dialogs
class _BackupDialog extends StatelessWidget {
  final MUser user;

  const _BackupDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return PopScope(
          canPop: !isLoading,
          child: AlertDialog(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            actionsPadding: const EdgeInsets.all(16),
            shape: AppTheme.shapeRoundedRectangle,
            titlePadding: AppTheme.titlePadding,

            title: CDialogTitle(
              icon: Icons.cloud_upload_rounded,
              text: "Backup Data",
            ),

            content: CDialogContent(
              text1: "Would you like to start the backup process?",
              text2:
                  "Please ensure you have a stable internet connection before proceeding.",
            ),

            actions: isLoading
                ? [const _LoadingIndicator()]
                : [
                    // Negative Action
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    // Positive Action
                    ElevatedButton(
                      style: AppTheme.btnStyle(theme),
                      onPressed: () async {
                        //  Update state to show the loading indicator
                        setState(() {
                          isLoading = true;
                        });

                        // Check if data exists for doing backup
                        final (noteCount, groupCount) = await (
                          noteController.getTotalNoteCount(),
                          groupController.getTotalGroupCount(),
                        ).wait;

                        if (noteCount == 0 &&
                            groupCount == 0 &&
                            context.mounted) {
                          Navigator.pop(context);
                          scaffoldMessenger("No data to backup");

                          return;
                        }

                        // Unified safe backup function
                        final bool backupSuccess =
                            await BackupService.backupToCloud(
                              userId: user.uid.toString(),
                            );

                        // Ensure the widget is still mounted before using the context
                        if (!context.mounted) return;

                        // Handle navigation based on results
                        if (backupSuccess) {
                          Navigator.pop(context);

                          scaffoldMessenger("Backup Completed");
                        } else {
                          Navigator.pop(context);
                          scaffoldMessenger("Backup Failed");
                        }
                      },
                      child: const Text(
                        "Backup Data",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
          ),
        );
      },
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  final NotificationService notificationService;

  const _LogoutDialog({required this.notificationService});

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return PopScope(
          canPop: !isLoading,
          child: AlertDialog(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            actionsPadding: const EdgeInsets.all(16),
            shape: AppTheme.shapeRoundedRectangle,
            titlePadding: AppTheme.titlePadding,

            title: const Text(textAlign: .center, 'Confirm Logout'),
            content: const Text(
              textAlign: .center,
              'Are you sure you want to log out of your account?\n\nLogging out will remove all locally stored data from this device. Make sure your latest changes have been backed up before continuing. You can sign in again later to restore your data.',
            ),

            actions: isLoading
                ? [const _LoadingIndicator()]
                : [
                    // Negative Action
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    // Positive Action
                    ElevatedButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () async {
                        setState(() => isLoading = true);

                        // Clear local data
                        final (notesCleared, groupsCleared) = await (
                          ClearDataService.clearNotes(),
                          ClearDataService.clearGroups(),
                        ).wait;

                        if (notesCleared && groupsCleared) {
                          logger.d("Local data cleared");
                        }

                        // Logout user
                        AuthenticationService auth = AuthenticationService(
                          context: context,
                        );
                        await auth.logOutuser();

                        // Cancel all notifications
                        await notificationService.cancelAll();

                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                    ),
                  ],
          ),
        );
      },
    );
  }
}

class _ImportDialog extends StatelessWidget {
  final MUser user;

  const _ImportDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    final theme = Theme.of(context);

    return StatefulBuilder(
      builder: (context, setState) {
        return PopScope(
          canPop: !isLoading,
          child: AlertDialog(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            actionsPadding: const EdgeInsets.all(16),
            shape: AppTheme.shapeRoundedRectangle,
            titlePadding: AppTheme.titlePadding,

            title: CDialogTitle(
              icon: Icons.cloud_download_rounded,
              text: "Import Data",
            ),

            content: CDialogContent(
              text1: "Would you like to start the import process?",
              text2:
                  "Please ensure you have a stable internet connection before proceeding.",
            ),

            actions: isLoading
                ? [const _LoadingIndicator()]
                : [
                    // Negative Action
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    // Positive Action
                    ElevatedButton(
                      style: AppTheme.btnStyle(theme),
                      onPressed: () async {
                        //  Update state to show the loading indicator
                        setState(() {
                          isLoading = true;
                        });

                        // Check both collections concurrently
                        final [noteResults, groupResults] = await Future.wait([
                          ImportService.checkNotesInFirebase(
                            userId: user.uid.toString(),
                          ),
                          ImportService.checkGroupsInFirebase(
                            userId: user.uid.toString(),
                          ),
                        ]);

                        // If BOTH are empty, there's nothing to sync. Exit early.
                        if (noteResults.isSnapEmpty &&
                            groupResults.isSnapEmpty &&
                            context.mounted) {
                          Navigator.pop(context, false);
                          scaffoldMessenger("No data to import");
                          return;
                        }

                        // Restore Process
                        final [
                          notesFetched,
                          groupsFetched,
                        ] = await Future.wait([
                          ImportService.restoreNotes(
                            userId: user.uid.toString(),
                            querySnapshot: noteResults.querySnapshot,
                            // Pass pre-fetched cloud notes snapshot
                          ),
                          ImportService.restoreGroups(
                            userId: user.uid.toString(),
                            querySnapshot: groupResults.querySnapshot,
                            // Pass pre-fetched cloud groups snapshot
                          ),
                        ]);

                        // Ensure the widget is still mounted before using the context
                        if (!context.mounted) return;

                        // Success means neither process threw an error
                        if (notesFetched != FetchStatus.error &&
                            groupsFetched != FetchStatus.error) {
                          Navigator.pop(context, true);
                          scaffoldMessenger("Import Completed");
                        } else {
                          Navigator.pop(context, false);
                          scaffoldMessenger("Import Failed");
                        }
                      },
                      child: const Text(
                        "Import Data",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
          ),
        );
      },
    );
  }
}

class _ClearDataDialog extends StatelessWidget {
  final String positiveBtnText, negativeBtnText;
  final bool localOnly;

  const _ClearDataDialog({
    required this.positiveBtnText,
    required this.negativeBtnText,
    required this.localOnly,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    String title = "Clear Local Data?",
        c1 = "Are you sure you want to delete local data?",
        c2 = "This action cannot be undone.";

    if (!localOnly) {
      title = "Clear All Data?";
      c1 = "Are you sure you want to delete all data?";
      c2 =
          "This will completely wipe your local data and permanently delete all backups from the cloud. This action is irreversible.";
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return PopScope(
          canPop: !isLoading,
          child: AlertDialog(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            actionsPadding: const EdgeInsets.all(16),
            shape: AppTheme.shapeRoundedRectangle,
            titlePadding: AppTheme.titlePadding,
            title: CDialogTitle(text: title, icon: Icons.delete),
            content: CDialogContent(text1: c1, text2: c2),
            actions: isLoading
                ? [const _LoadingIndicator()]
                : [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(negativeBtnText),
                    ),
                    TextButton(
                      onPressed: () async {
                        //  Update state to show the loading indicator
                        setState(() {
                          isLoading = true;
                        });

                        if (localOnly) {
                          // Clear Local Data
                          await clearLocalData(context);
                        } else {
                          // Clear All Data
                          await clearAllData(context);
                        }
                      },
                      child: Text(
                        positiveBtnText,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
          ),
        );
      },
    );
  }

  Future<void> clearLocalData(BuildContext context) async {
    // Check if data exists
    final (noteCount, groupCount) = await (
      noteController.getTotalNoteCount(),
      groupController.getTotalGroupCount(),
    ).wait;

    // Process results
    if (noteCount == 0 && groupCount == 0 && context.mounted) {
      Navigator.pop(context, false);
      scaffoldMessenger("No data to clear");

      return;
    }

    // Calling Isar clear functions
    final (notesCleared, groupsCleared) = await (
      ClearDataService.clearNotes(),
      ClearDataService.clearGroups(),
    ).wait;

    if (notesCleared && groupsCleared) {
      Navigator.pop(context, true);
      scaffoldMessenger("Local data cleared successfully");
    } else {
      Navigator.pop(context, false);
      scaffoldMessenger("Failed to clear some local data");
    }
  }

  Future<void> clearAllData(BuildContext context) async {
    // User check
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null && context.mounted) {
      Navigator.pop(context, false);
      scaffoldMessenger("User not authenticated.");
      return;
    }

    // Trigger all 4 checks simultaneously
    final (noteCount, groupCount, cloudNotesSnap, cloudGroupsSnap) = await (
      noteController.getTotalNoteCount(),
      groupController.getTotalGroupCount(),
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Notes')
          .limit(1)
          .get(),
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Groups')
          .limit(1)
          .get(),
    ).wait;

    // Process results
    bool localExists = noteCount > 0 || groupCount > 0;
    bool cloudExists =
        cloudNotesSnap.docs.isNotEmpty || cloudGroupsSnap.docs.isNotEmpty;

    // Exit early if nothing exists anywhere
    if (!localExists && !cloudExists && context.mounted) {
      Navigator.pop(context, false);
      scaffoldMessenger("No data found to clear.");
      return;
    }

    // Setup flags
    bool localNotesCleared = true;
    bool localGroupsCleared = true;
    bool cloudNotesCleared = true;
    bool cloudGroupsCleared = true;

    // Clear Local Data simultaneously if it exists
    if (localExists) {
      final (notesCleared, groupsCleared) = await (
        ClearDataService.clearNotes(),
        ClearDataService.clearGroups(),
      ).wait;

      localNotesCleared = notesCleared;
      localGroupsCleared = groupsCleared;
      logger.d("Local data cleared");
    }

    // Clear Cloud Data simultaneously if it exists
    if (cloudExists) {
      final (notesCleared, groupsCleared) = await (
        ClearDataService.clearFirebaseNotes(userId!),
        ClearDataService.clearFirebaseGroups(userId),
      ).wait;

      cloudNotesCleared = notesCleared;
      cloudGroupsCleared = groupsCleared;
      logger.d("Cloud data cleared");
    }

    if (cloudNotesCleared &&
        cloudGroupsCleared &&
        localNotesCleared &&
        localGroupsCleared) {
      Navigator.pop(context, true);
      scaffoldMessenger("All data permanently wiped");
    } else {
      Navigator.pop(context, false);
      scaffoldMessenger("Wipe incomplete. Some data failed to clear.");
    }
  }
}

// Stateless Widgets
class _SectionGroup extends StatelessWidget {
  final String title;
  final ThemeData theme;
  final bool isDark;
  final List<Widget> children;

  const _SectionGroup({
    required this.title,
    required this.theme,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: isDark ? 0.2 : 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _CDivider extends StatelessWidget {
  final ThemeData theme;
  const _CDivider({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 56, // Indent to align with text
      endIndent: 0,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

class _CMenuItem extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? tWidget;

  const _CMenuItem({
    required this.context,
    required this.icon,
    required this.title,
    this.onTap,
    this.tWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      leading: Icon(
        icon,
        color: isDark ? colorScheme.primary : AppColors.lThirdColor,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          fontFamily: 'inter',
        ),
      ),
      trailing:
          tWidget ??
          (onTap != null
              ? Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant)
              : null),
    );
  }
}

class _LogInOutButton extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onPressed;

  const _LogInOutButton({required this.onPressed, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isLogin ? null : theme.colorScheme.errorContainer,
        foregroundColor: isLogin ? null : theme.colorScheme.onErrorContainer,
        padding: EdgeInsets.symmetric(
          horizontal: isLogin ? 32 : 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        onPressed();
      },
      icon: Icon(isLogin ? Icons.login : Icons.logout_rounded),
      label: Text(isLogin ? "Log In" : "Log Out"),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: LinearProgressIndicator(
          color: isDark ? AppColors.lFirstColor : AppColors.dFirstColor,
          backgroundColor: isDark
              ? AppColors.dFirstColor
              : AppColors.lFirstColor,
        ),
      ),
    );
  }
}
