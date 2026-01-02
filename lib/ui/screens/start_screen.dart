import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF83CFD1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF2AAAAD),
              borderRadius: BorderRadius.circular(16),
            ),
            // ClipRRect ensures the image doesn't bleed outside the rounded corners
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Text and Button Content
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ALWAYS\nFORGETTING TO\nTAKE YOUR\nMEDECINE?", // Spelling matched to image
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, AppRoutes.main);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Get Started Now",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40), // Space at bottom
                      ],
                    ),
                  ),
                  
                  // Positioned Illustration
                  Positioned(
                    right: -20,
                    bottom: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Image.asset(
                        'assets/user_start.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}