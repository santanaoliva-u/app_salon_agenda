import 'dart:async';
import 'package:flutter/material.dart';
import 'package:salon_app/screens/introduction/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isAnimate = true;
  bool isClicked = false;

  final width = 50;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), (() {
      setState(() {
        isAnimate = false;
      });
    }));

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: ((context) => const OnBoardingScreen())));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.1, // 10% of screen width
              vertical: screenHeight * 0.05, // 5% of screen height
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 3,
                    child: AnimatedPadding(
                      padding: EdgeInsets.only(top: isAnimate ? 20 : 0),
                      duration: const Duration(seconds: 3),
                      curve: Curves.easeInOutCubicEmphasized,
                      child: AnimatedOpacity(
                        opacity: isAnimate ? 0 : 1,
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInCubic,
                        child: CircleAvatar(
                          backgroundColor: Colors.purple,
                          radius: screenWidth * 0.2, // Responsive radius
                          foregroundImage: const NetworkImage(
                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlsWQc8piebZMl-wQAD71xoEFovIAxB0bCYURrbrb1y_URNyoW6I0q6QpbKo_Fo6ZBDRw&usqp=CAU"),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03), // Responsive spacing
                  Flexible(
                    flex: 2,
                    child: AnimatedPadding(
                      padding: EdgeInsets.only(top: isAnimate ? 20 : 0),
                      duration: const Duration(seconds: 3),
                      curve: Curves.easeInOutCubicEmphasized,
                      child: AnimatedOpacity(
                        opacity: isAnimate ? 0 : 1,
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInCubic,
                        child: Text(
                          "Evita Salon",
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize:
                                screenWidth * 0.08, // Responsive font size
                            letterSpacing: 1.3,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
