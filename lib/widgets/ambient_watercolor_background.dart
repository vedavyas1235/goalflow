import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class AmbientWatercolorBackground extends StatefulWidget {
  final Widget? child;

  const AmbientWatercolorBackground({super.key, this.child});

  @override
  State<AmbientWatercolorBackground> createState() => _AmbientWatercolorBackgroundState();
}

class _AmbientWatercolorBackgroundState extends State<AmbientWatercolorBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blobController.dispose();
    super.dispose();
  }

  Color _getPastelColor(double phase, double hueOffset, Brightness brightness) {
    final double hue = (phase * 360 + hueOffset) % 360;
    if (brightness == Brightness.dark) {
      return HSVColor.fromAHSV(1.0, hue, 0.6, 0.35).toColor();
    }
    return HSVColor.fromAHSV(1.0, hue, 0.18, 0.99).toColor();
  }

  Widget _buildBlob(Color baseColor, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            baseColor.withOpacity(0.7),
            baseColor.withOpacity(0.3),
            baseColor.withOpacity(0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  // Pre-calculated static colors for performance
  late Color _color1;
  late Color _color2;
  late Color _color3;
  late Color _color4;
  late Color _color5;
  late Color _color6;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    _color1 = _getPastelColor(0.2, 195, brightness);
    _color2 = _getPastelColor(0.4, 140, brightness);
    _color3 = _getPastelColor(0.6, 320, brightness);
    _color4 = _getPastelColor(0.8, 40, brightness);
    _color5 = _getPastelColor(0.9, 350, brightness);
    _color6 = _getPastelColor(1.0, 65, brightness);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base canvas
        ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),

        // Apple-style ambient side watercolor splashes
        AnimatedBuilder(
          animation: _blobController,
          builder: (context, _) {
            final t = _blobController.value * math.pi * 2;
            return Stack(
              children: [
                // Splash 1: Left-Top side drifting slowly
                Positioned(
                  top: size.height * 0.05 + (math.sin(t * 1.1) * 90 + math.cos(t * 0.7) * 50),
                  left: size.width * -0.25 + (math.cos(t * 0.9) * 60 + math.sin(t * 1.3) * 40),
                  child: _buildBlob(_color1, 520),
                ),
                // Splash 2: Right-Top side drifting slowly
                Positioned(
                  top: size.height * 0.12 + (math.cos(t * 0.8) * 80 + math.sin(t * 1.4) * 60),
                  right: size.width * -0.28 + (math.sin(t * 1.0) * 70 + math.cos(t * 0.6) * 40),
                  child: _buildBlob(_color2, 480),
                ),
                // Splash 3: Mid-Left side splash
                Positioned(
                  top: size.height * 0.45 + (math.sin(t * 0.9) * 110 + math.cos(t * 1.2) * 50),
                  left: size.width * -0.3 + (math.cos(t * 1.1) * 70),
                  child: _buildBlob(_color3, 490),
                ),
                // Splash 4: Mid-Right side splash
                Positioned(
                  top: size.height * 0.48 + (math.cos(t * 1.0) * 100 + math.sin(t * 0.8) * 60),
                  right: size.width * -0.3 + (math.sin(t * 1.2) * 70),
                  child: _buildBlob(_color4, 500),
                ),
                // Splash 5: Left-Bottom side splash
                Positioned(
                  bottom: size.height * -0.1 + (math.cos(t * 1.2) * 90 + math.sin(t * 0.6) * 50),
                  left: size.width * -0.2 + (math.sin(t * 0.8) * 80),
                  child: _buildBlob(_color5, 530),
                ),
                // Splash 6: Right-Bottom side splash
                Positioned(
                  bottom: size.height * -0.12 + (math.sin(t * 1.0) * 100 + math.cos(t * 1.3) * 60),
                  right: size.width * -0.22 + (math.cos(t * 0.9) * 80),
                  child: _buildBlob(_color6, 510),
                ),
                // Luminous wash to blend colors softly
                Container(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4)),
              ],
            );
          },
        ),

        // Foreground content
        if (widget.child != null) widget.child!,
      ],
    );
  }
}
