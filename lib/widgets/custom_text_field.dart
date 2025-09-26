import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool isTablet;
  final Function(String)? onSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.prefixIcon,
    this.suffixIcon,
    required this.isTablet,
    this.onSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _borderAnimation;
  late Animation<double> _borderWidthAnimation;
  late Animation<Color?> _shadowColorAnimation;
  late Animation<Color?> _backgroundAnimation;
  late Animation<Color?> _iconColorAnimation;

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _borderAnimation = ColorTween(
      begin: Colors.white.withValues(alpha: 0.2),
      end: const Color(0xFF4a5bb8),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _borderWidthAnimation = Tween<double>(
      begin: 1.0,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _shadowColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: const Color(0xFF4a5bb8).withValues(alpha: 0.25),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _backgroundAnimation = ColorTween(
      begin: const Color(0xFF1A1A23).withValues(alpha: 0.6),
      end: const Color(0xFF23234A).withValues(alpha: 0.8),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _iconColorAnimation = ColorTween(
      begin: Colors.white.withValues(alpha: 0.6),
      end: const Color(0xFF4a5bb8),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });

    if (_isFocused) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _backgroundAnimation.value,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  _borderAnimation.value ?? Colors.white.withValues(alpha: 0.2),
              width: _borderWidthAnimation.value,
            ),
            boxShadow: [
              BoxShadow(
                color: _shadowColorAnimation.value ?? Colors.transparent,
                blurRadius: _isFocused ? 18 : 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            onSubmitted: widget.onSubmitted,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isTablet ? 16 : 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: widget.isTablet ? 16 : 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                widget.prefixIcon,
                color: _iconColorAnimation.value,
                size: widget.isTablet ? 22 : 20,
              ),
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.isTablet ? 20 : 16,
                vertical: widget.isTablet ? 20 : 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
