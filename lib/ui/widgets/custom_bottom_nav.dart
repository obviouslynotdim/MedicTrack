import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        // This allows the floating button to overflow the container boundaries
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 65,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navIcon(Icons.home, 0),
                  _navIcon(Icons.bar_chart, 1),
                  const SizedBox(width: 40), // space for center button
                  _navIcon(Icons.history, 2),
                  _navIcon(Icons.person, 3),
                ],
              ),
            ),
          ),

          // Center + Button
          Positioned(
            top: -10, // Slightly raised
            child: GestureDetector(
              onTap: onAddTap,
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    return IconButton(
      onPressed: () => onTap(index),
      icon: Icon(
        icon,
        size: 26,
        color: currentIndex == index ? Colors.teal : Colors.grey,
      ),
    );
  }
}