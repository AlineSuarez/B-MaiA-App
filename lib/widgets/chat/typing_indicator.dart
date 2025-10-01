import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final bool isDark;
  final bool isTablet;

  const TypingIndicator({
    super.key,
    required this.isDark,
    required this.isTablet,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();

    _animations = List.generate(3, (index) {
      final start = index * 0.2;
      final end = start + 0.4;
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.4,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.0,
            end: 0.4,
          ).chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end.clamp(0.0, 1.0)),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: widget.isTablet ? 20 : 16,
        right: widget.isTablet ? 20 : 16,
        bottom: widget.isTablet ? 16 : 12,
      ),
      child: Row(
        children: [
          // Avatar de B-MaiA
          Container(
            width: widget.isTablet ? 36 : 32,
            height: widget.isTablet ? 36 : 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2f43a7), Color(0xFF4a5bb8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(widget.isTablet ? 10 : 8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2f43a7).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: widget.isTablet ? 20 : 18,
            ),
          ),
          SizedBox(width: widget.isTablet ? 12 : 10),

          // Contenedor de los puntos animados
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isTablet ? 20 : 16,
              vertical: widget.isTablet ? 16 : 14,
            ),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(widget.isTablet ? 20 : 18),
              border: Border.all(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _animations[index],
                  builder: (context, child) {
                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: widget.isTablet ? 3 : 2.5,
                      ),
                      child: Transform.scale(
                        scale: _animations[index].value,
                        child: Container(
                          width: widget.isTablet ? 10 : 8,
                          height: widget.isTablet ? 10 : 8,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4a5bb8,
                            ).withValues(alpha: _animations[index].value),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
