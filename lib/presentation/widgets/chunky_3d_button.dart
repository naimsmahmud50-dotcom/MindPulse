import 'package:flutter/material.dart';

class Chunky3DButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color color;
  final Color shadowColor;
  final double height;
  final double? width;
  final double depth;
  final BorderRadiusGeometry borderRadius;

  const Chunky3DButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.color,
    required this.shadowColor,
    this.height = 54.0,
    this.width,
    this.depth = 5.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<Chunky3DButton> createState() => _Chunky3DButtonState();
}

class _Chunky3DButtonState extends State<Chunky3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final double currentOffset = _isPressed ? widget.depth : 0.0;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.width,
        height: widget.height + widget.depth,
        child: Stack(
          children: [
            // 3D Bottom Shadow Bevel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: widget.height,
              child: Container(
                decoration: BoxDecoration(
                  color: isEnabled ? widget.shadowColor : Colors.grey.shade800,
                  borderRadius: widget.borderRadius,
                ),
              ),
            ),
            // Push-down Face
            AnimatedPositioned(
              duration: const Duration(milliseconds: 60),
              top: currentOffset,
              left: 0,
              right: 0,
              height: widget.height,
              child: Container(
                decoration: BoxDecoration(
                  color: isEnabled ? widget.color : Colors.grey.shade700,
                  borderRadius: widget.borderRadius,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.2,
                  ),
                ),
                child: Center(child: widget.child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
