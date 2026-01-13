import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavbarItem> items;

  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<CustomBottomNavbar> createState() => _CustomBottomNavbarState();
}

class _CustomBottomNavbarState extends State<CustomBottomNavbar> {
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(CustomBottomNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        _activeIndex = widget.currentIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always sync with the current index from parent widget
    _activeIndex = widget.currentIndex;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              widget.items.length,
              (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    _activeIndex = index;
                  });
                  widget.onTap(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: _activeIndex == index ? 20 : 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: _activeIndex == index
                        ? LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                            ],
                          )
                        : null,
                    color: _activeIndex == index
                        ? null
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _activeIndex == index
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.items[index].icon,
                        color: _activeIndex == index
                            ? Colors.white
                            : Colors.grey.shade600,
                        size: 24,
                      ),
                      if (_activeIndex == index) ...[
                        const SizedBox(width: 8),
                        Text(
                          widget.items[index].label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavbarItem {
  final IconData icon;
  final String label;

  BottomNavbarItem({
    required this.icon,
    required this.label,
  });
}