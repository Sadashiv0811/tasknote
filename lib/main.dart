import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Service/s_notification.dart';
import 'package:tasknote/Other/routes.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/Service/s_shared_pref.dart';
import 'package:tasknote/Other_Views/v_splash.dart';
import 'package:tasknote/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize AppCheck.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode
        ? const AppleDebugProvider()
        : const AppleAppAttestProvider(),
  );

  // Initialize the Notification Channel
  await NotificationService().initialize();

  initializeTheme();

  runApp(ProviderScope(child: const MyApp()));
}

void initializeTheme() async {
  String mode = await SharedPrefService.getMode();
  if (mode == "dark") {
    themeNotifier.value = ThemeMode.dark;
  } else if (mode == "light") {
    themeNotifier.value = ThemeMode.light;
  } else {
    return;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TaskNote',
          scaffoldMessengerKey: snackbarKey,
          themeMode: mode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          onGenerateRoute: (settings) => Routes.generateRoute(settings),
          home: const VSplash(),
        );
      },
    );
  }
}
