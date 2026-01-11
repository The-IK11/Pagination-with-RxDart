import 'package:flutter/material.dart';

/// A beautiful custom loading indicator widget with animations and styling.
class CustomLoadingIndicator extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final Color? secondaryColor;
  final Duration animationDuration;

  const CustomLoadingIndicator({
    super.key,
    this.size = 60.0,
    this.primaryColor = Colors.greenAccent,
    this.secondaryColor,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated circular spinner
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2.0 * 3.14159,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (widget.secondaryColor ?? Colors.grey[300])!,
                        width: 4,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Rotating gradient border
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                widget.primaryColor,
                                (widget.secondaryColor ?? Colors.greenAccent[100])!,
                                widget.primaryColor.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Loading text with fade animation
            FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(_controller),
              child: const Text(
                'Loading more items...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
