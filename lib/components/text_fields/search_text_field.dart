// ignore_for_file: unused_field

import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Cari di sini...',
    this.prefixIcon,
    this.suffixIcon,
    this.onClear,
    this.elevation = 2,
    this.borderRadius = 16,
  });

  final TextEditingController controller;
  final Function(String?) onChanged;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onClear;
  final double elevation;
  final double borderRadius;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  
  bool _isFocused = false;
  bool _hasText = false;
  final FocusNode _focusNode = FocusNode();

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
    
    _colorAnimation = ColorTween(
      begin: Colors.grey.shade100,
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
    _hasText = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onTextChange() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _clearText() {
    widget.controller.clear();
    widget.onChanged('');
    if (widget.onClear != null) {
      widget.onClear!();
    }
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: _isFocused 
                      ? colorScheme.primary.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: _isFocused ? 12 : 8,
                  offset: const Offset(0, 4),
                  spreadRadius: _isFocused ? 2 : 0,
                ),
              ],
              border: Border.all(
                color: _isFocused 
                    ? colorScheme.primary.withOpacity(0.5)
                    : Colors.grey.shade300,
                width: _isFocused ? 2 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                onTap: () => _focusNode.requestFocus(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Prefix Icon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: widget.prefixIcon ??
                            Icon(
                              Icons.search_rounded,
                              color: _isFocused
                                  ? colorScheme.primary
                                  : Colors.grey.shade600,
                              size: 22,
                            ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Text Field
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          onChanged: widget.onChanged,
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: widget.hintText,
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                      
                      // Suffix Icon or Clear Button
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _hasText
                            ? GestureDetector(
                                onTap: _clearText,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : widget.suffixIcon != null
                                ? widget.suffixIcon!
                                : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Advanced Search TextField with more features
class AdvancedSearchTextField extends StatefulWidget {
  const AdvancedSearchTextField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Cari di sini...',
    this.suggestions = const [],
    this.onSuggestionTap,
    this.showSuggestions = true,
    this.maxSuggestions = 5,
    this.suggestionBuilder,
  });

  final TextEditingController controller;
  final Function(String?) onChanged;
  final String hintText;
  final List<String> suggestions;
  final Function(String)? onSuggestionTap;
  final bool showSuggestions;
  final int maxSuggestions;
  final Widget Function(String suggestion)? suggestionBuilder;

  @override
  State<AdvancedSearchTextField> createState() => _AdvancedSearchTextFieldState();
}

class _AdvancedSearchTextFieldState extends State<AdvancedSearchTextField> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChange);
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && widget.showSuggestions) {
      _showSuggestionsOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onTextChange() {
    final query = widget.controller.text.toLowerCase();
    if (query.isEmpty) {
      _filteredSuggestions = widget.suggestions.take(widget.maxSuggestions).toList();
    } else {
      _filteredSuggestions = widget.suggestions
          .where((suggestion) => suggestion.toLowerCase().contains(query))
          .take(widget.maxSuggestions)
          .toList();
    }
    
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _showSuggestionsOverlay() {
    if (_overlayEntry != null) return;
    
    _filteredSuggestions = widget.suggestions.take(widget.maxSuggestions).toList();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: context.findRenderObject()!.paintBounds.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _filteredSuggestions.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredSuggestions.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final suggestion = _filteredSuggestions[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.search, size: 18),
                          title: widget.suggestionBuilder?.call(suggestion) ??
                              Text(
                                suggestion,
                                style: const TextStyle(fontSize: 14),
                              ),
                          onTap: () {
                            widget.controller.text = suggestion;
                            widget.onSuggestionTap?.call(suggestion);
                            _focusNode.unfocus();
                          },
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SearchTextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        hintText: widget.hintText,
      ),
    );
  }
}