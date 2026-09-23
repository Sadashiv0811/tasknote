import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tasknote/Group/c_group.dart';
import 'package:tasknote/Note/c_note.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Reminder/c_reminder.dart';
import 'package:tasknote/User/c_user.dart';
import 'package:tasknote/Other/routes.dart';

final NoteController noteController = NoteController();
final GroupNotesController groupController = GroupNotesController();
final UserController userController = UserController();
final ReminderController reminderController = ReminderController();

class VSplash extends StatefulWidget {
  const VSplash({super.key});

  @override
  State<VSplash> createState() => _VSplashState();
}

class _VSplashState extends State<VSplash> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Start the minimum display timer (e.g., 1.8 seconds for animations to shine)
    final minimumDisplayTimer = Future.delayed(
      const Duration(milliseconds: 2500),
    );

    // Start warming up the Isar local database instance in parallel
    final controllersInitialization = Future.wait([
      noteController.init(),
      groupController.init(),
      userController.init(),
      reminderController.init(),
    ]);

    try {
      // Wait for ALL parallel futures to complete before moving forward
      await Future.wait([minimumDisplayTimer, controllersInitialization]);
    } catch (e) {
      // Handle database or notification boot errors gracefully
      debugPrint("Error initializing Isar Database on boot: $e");
    }

    // Navigate instantly the split-second everything is ready
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handling width safely if CommonFunctions is generic, otherwise use MediaQuery
    final double logoSize = getWidth(context, 0.45);

    const colors = [Color(0xFF54acbf), Color(0xFF26658c), Color(0xFF023859)];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ).animate().scale(duration: 2000.ms, curve: Curves.easeInOut),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The Logo
                  _buildLogo(logoSize),

                  const SizedBox(height: 40),

                  // The App Name
                  const Text(
                        'TaskNote',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'average',
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 4),
                              blurRadius: 15.0,
                              color: Color.fromRGBO(0, 0, 0, 0.2),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 300.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .blurXY(begin: 10, end: 0, duration: 600.ms),

                  const SizedBox(height: 12),

                  // The Slogan
                  const Text(
                        'Plan smarter. Act faster.',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'average',
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 600.ms)
                      .slideY(begin: 0.2, end: 0, duration: 600.ms),
                ],
              ),
            ),

            // Loading Indicator at bottom
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ).animate().fadeIn(delay: 1000.ms),
            ),

            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ).animate().scale(duration: 2000.ms, curve: Curves.easeInOut),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(double size) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 255, 255, 255),
                blurRadius: 30,
                spreadRadius: 0,
                blurStyle: BlurStyle.outer,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          padding: const EdgeInsets.all(
            25.0,
          ), // Padding inside the white circle
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  blurRadius: 35,
                  spreadRadius: 0,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Image.asset(
              'assets/icon/splashLogo.png',
              fit: BoxFit.contain,
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        // Entrance Animation
        .scale(
          duration: 800.ms,
          curve: Curves.elasticOut,
          begin: const Offset(0.5, 0.5),
        )
        .fade(duration: 500.ms)
        .shimmer(
          delay: 600.ms,
          duration: 1200.ms,
          color: Colors.grey.withValues(alpha: 0.2),
        )
        // Continuous Floating Animation (Breathing) after entrance
        .then()
        .moveY(begin: 0, end: -10, duration: 1500.ms, curve: Curves.easeInOut);
  }
}
