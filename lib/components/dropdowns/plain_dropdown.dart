import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlainDropdown<T> extends StatefulWidget {
  final String label;
  final String? hint;
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;
  final bool enabled;
  final Widget Function(T)? itemBuilder;
  final double? maxHeight;

  const PlainDropdown({
    super.key,
    required this.label,
    this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
    this.itemBuilder,
    this.maxHeight,
  });

  @override
  State<PlainDropdown<T>> createState() => _PlainDropdownState<T>();
}

class _PlainDropdownState<T> extends State<PlainDropdown<T>>
    with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern floating label
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              color: _isFocused 
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
        
        // Animated dropdown container
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: _isFocused || _isHovered
                        ? LinearGradient(
                            colors: [
                              colorScheme.surface,
                              colorScheme.surface.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _isFocused || _isHovered
                        ? null
                        : colorScheme.surface.withOpacity(0.7),
                    border: Border.all(
                      color: _isFocused
                          ? colorScheme.primary
                          : _isHovered
                              ? colorScheme.primary.withOpacity(0.5)
                              : colorScheme.outline.withOpacity(0.3),
                      width: _isFocused ? 2 : 1,
                    ),
                    boxShadow: _isFocused
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : _isHovered
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: widget.enabled ? () {} : null,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.prefixIcon != null ? 16 : 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            // Prefix Icon
                            if (widget.prefixIcon != null) ...[
                              Container(
                                padding: const EdgeInsets.only(right: 12),
                                child: Icon(
                                  widget.prefixIcon,
                                  color: _isFocused
                                      ? colorScheme.primary
                                      : colorScheme.onSurface.withOpacity(0.5),
                                  size: 20,
                                ),
                              ),
                            ],
                            
                            // Dropdown Content
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<T>(
                                  value: widget.value,
                                  hint: widget.hint != null
                                      ? Text(
                                          widget.hint!,
                                          style: GoogleFonts.inter(
                                            color: colorScheme.onSurface.withOpacity(0.5),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      : null,
                                  isExpanded: true,
                                  icon: const SizedBox.shrink(), // Hide default icon
                                  style: GoogleFonts.inter(
                                    color: colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  dropdownColor: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  elevation: 8,
                                  menuMaxHeight: widget.maxHeight ?? 300,
                                  items: widget.items.map((item) {
                                    return DropdownMenuItem<T>(
                                      value: item,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        child: widget.itemBuilder != null
                                            ? widget.itemBuilder!(item)
                                            : Text(
                                                item.toString(),
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: widget.enabled ? (value) {
                                    setState(() {
                                      _isFocused = true;
                                    });
                                    _animationController.forward().then((_) {
                                      _animationController.reverse();
                                      setState(() {
                                        _isFocused = false;
                                      });
                                    });
                                    widget.onChanged?.call(value);
                                  } : null,
                                  onTap: () {
                                    setState(() {
                                      _isFocused = true;
                                    });
                                    _animationController.forward();
                                  },
                                ),
                              ),
                            ),
                            
                            // Custom Dropdown Arrow
                            AnimatedBuilder(
                              animation: _rotationAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotationAnimation.value * 3.14159,
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: _isFocused
                                        ? colorScheme.primary
                                        : colorScheme.onSurface.withOpacity(0.5),
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Validation Error Message
        if (widget.validator != null)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: widget.validator!(widget.value) != null ? 24 : 0,
            child: widget.validator!(widget.value) != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Text(
                      widget.validator!(widget.value)!,
                      style: GoogleFonts.inter(
                        color: colorScheme.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                : null,
          ),
      ],
    );
  }
}