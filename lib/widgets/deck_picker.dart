import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../viewmodels/Mainviewmodel.dart';

class DeckPicker extends StatefulWidget {
  final MainViewModel vm;
  final bool isSmallScreen;

  const DeckPicker({super.key, required this.vm, required this.isSmallScreen});

  @override
  State<DeckPicker> createState() => _DeckPickerState();
}

class _DeckPickerState extends State<DeckPicker> {
  static const Map<String, String> _suitNames = {
    'h': 'Kier',
    'd': 'Karo',
    'c': 'Trefl',
    's': 'Pik',
  };

  String? _activeSuit;
  int? _activeRankIndex;

  Color _suitColor(String suit) {
    switch (suit) {
      case 'h':
        return AppColors.hearts;
      case 'd':
        return AppColors.diamonds;
      case 'c':
        return AppColors.clubs;
      case 's':
        return AppColors.spades;
      default:
        return AppColors.accent;
    }
  }

  IconData _suitIcon(String suit) {
    switch (suit) {
      case 'h':
        return Icons.favorite;
      case 'd':
        return Icons.change_history;
      case 'c':
        return Icons.filter_vintage;
      case 's':
        return Icons.navigation;
      default:
        return Icons.casino;
    }
  }

  int? _rankIndexFromOffset(
    Offset localPosition,
    Offset center,
    double innerRadius,
    double outerRadius,
  ) {
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    if (distance < innerRadius || distance > outerRadius) {
      return null;
    }

    final angle = math.atan2(dy, dx);
    final normalized = angle < 0 ? angle + 2 * math.pi : angle;
    final shifted = (normalized + math.pi / 2) % (2 * math.pi);
    final step = (2 * math.pi) / MainViewModel.ranks.length;
    final index = (shifted / step).round() % MainViewModel.ranks.length;
    return index;
  }

  void _commitSelection(String suit) {
    final index = _activeRankIndex;
    if (index == null) {
      setState(() {
        _activeSuit = null;
        _activeRankIndex = null;
      });
      return;
    }

    final rank = MainViewModel.ranks[index];
    if (!widget.vm.isCardAvailable(suit, rank)) {
      setState(() {
        _activeSuit = null;
        _activeRankIndex = null;
      });
      return;
    }

    widget.vm.onCardSelected('$suit$rank');
    setState(() {
      _activeSuit = null;
      _activeRankIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.withOpacity(AppColors.accent, 0.25),
            width: 1.5,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.withOpacity(Colors.black, 0.3),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.withOpacity(AppColors.textSecondary, 0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          IgnorePointer(
            ignoring: !widget.vm.addCards,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: widget.vm.addCards ? 1.0 : 0.7,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  alignment: Alignment.bottomCenter,
                  child: _buildSuitSelector(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuitSelector() {
    final activeSuit = _activeSuit;
    final tileHeight = widget.isSmallScreen ? 82.0 : 96.0;
    final rowGap = widget.isSmallScreen ? 10.0 : 12.0;
    final colGap = widget.isSmallScreen ? 10.0 : 12.0;

    final ringRadius = widget.isSmallScreen ? 92.0 : 110.0;
    final itemSize = widget.isSmallScreen ? 42.0 : 48.0;
    final innerRadius = widget.isSmallScreen ? 56.0 : 68.0;
    final outerRadius = ringRadius + itemSize * 0.8;

    final gridHeight = (tileHeight * 2) + rowGap;
    final topOverflow = activeSuit == null
      ? 0.0
      : math.max(0.0, outerRadius - (tileHeight / 2) + 12);
    final totalHeight = gridHeight + topOverflow;
    final gridTop = topOverflow;

    return LayoutBuilder(
      key: ValueKey('selector-${activeSuit ?? 'none'}'),
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - colGap) / 2;
        final centers = <String, Offset>{
          MainViewModel.suits[0]: Offset(tileWidth / 2, gridTop + (tileHeight / 2)),
          MainViewModel.suits[1]: Offset(
            tileWidth + colGap + (tileWidth / 2),
            gridTop + (tileHeight / 2),
          ),
          MainViewModel.suits[2]: Offset(
            tileWidth / 2,
            gridTop + tileHeight + rowGap + (tileHeight / 2),
          ),
          MainViewModel.suits[3]: Offset(
            tileWidth + colGap + (tileWidth / 2),
            gridTop + tileHeight + rowGap + (tileHeight / 2),
          ),
        };

        Offset? ringCenter;
        if (activeSuit != null) {
          ringCenter = centers[activeSuit];
        }

        return SizedBox(
          width: constraints.maxWidth,
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (activeSuit != null && ringCenter != null)
                Builder(
                  builder: (context) {
                    final String suit = activeSuit;
                    final Offset center = ringCenter!;

                    return Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (details) {
                          final renderBox = context.findRenderObject() as RenderBox;
                          final localPos = renderBox.globalToLocal(details.globalPosition);
                          setState(() {
                            _activeRankIndex = _rankIndexFromOffset(
                              localPos,
                              center,
                              innerRadius,
                              outerRadius,
                            );
                          });
                        },
                        onPanUpdate: (details) {
                          final renderBox = context.findRenderObject() as RenderBox;
                          final localPos = renderBox.globalToLocal(details.globalPosition);
                          setState(() {
                            _activeRankIndex = _rankIndexFromOffset(
                              localPos,
                              center,
                              innerRadius,
                              outerRadius,
                            );
                          });
                        },
                        onPanEnd: (_) {
                          _commitSelection(suit);
                        },
                        onPanCancel: () {
                          setState(() {
                            _activeSuit = null;
                            _activeRankIndex = null;
                          });
                        },
                        onTapDown: (details) {
                          final renderBox = context.findRenderObject() as RenderBox;
                          final localPos = renderBox.globalToLocal(details.globalPosition);
                          final rankIndex = _rankIndexFromOffset(
                            localPos,
                            center,
                            innerRadius,
                            outerRadius,
                          );
                          setState(() => _activeRankIndex = rankIndex);
                        },
                        onTapUp: (_) => _commitSelection(suit),
                        onTapCancel: () {
                          setState(() => _activeRankIndex = null);
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: center.dx - ringRadius,
                              top: center.dy - ringRadius,
                              child: Container(
                                width: ringRadius * 2,
                                height: ringRadius * 2,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.withOpacity(
                                      _suitColor(suit),
                                      0.5,
                                    ),
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            ),
                            ...List.generate(MainViewModel.ranks.length, (index) {
                              final rank = MainViewModel.ranks[index];
                              final angle = (-math.pi / 2) +
                                  (2 * math.pi * index / MainViewModel.ranks.length);
                              final x = center.dx + (math.cos(angle) * ringRadius) -
                                  (itemSize / 2);
                              final y = center.dy + (math.sin(angle) * ringRadius) -
                                  (itemSize / 2);
                              final available = widget.vm.isCardAvailable(suit, rank);
                              final isActive = _activeRankIndex == index;
                              final suitColor = _suitColor(suit);

                              return Positioned(
                                left: x,
                                top: y,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  width: itemSize,
                                  height: itemSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: !available
                                        ? AppColors.surfaceLight
                                        : isActive
                                            ? suitColor
                                            : AppColors.withOpacity(suitColor, 0.2),
                                    border: Border.all(
                                      color: available
                                          ? AppColors.withOpacity(suitColor, isActive ? 1.0 : 0.7)
                                          : AppColors.withOpacity(
                                              AppColors.textSecondary,
                                              0.2,
                                            ),
                                      width: isActive ? 2.2 : 1.3,
                                    ),
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: AppColors.withOpacity(suitColor, 0.4),
                                              blurRadius: 8,
                                              spreadRadius: 0.5,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      rank,
                                      style: TextStyle(
                                        color: !available
                                            ? AppColors.withOpacity(
                                                AppColors.textSecondary,
                                                0.4,
                                              )
                                            : AppColors.textPrimary,
                                        fontSize: widget.isSmallScreen ? 13 : 14,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              Positioned(
                left: 0,
                right: 0,
                top: gridTop,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SuitTile(
                            label: _suitNames[MainViewModel.suits[0]]!,
                            color: _suitColor(MainViewModel.suits[0]),
                            icon: _suitIcon(MainViewModel.suits[0]),
                            compact: widget.isSmallScreen,
                            selected: activeSuit == MainViewModel.suits[0],
                            onLongPressStart: (details) {
                              setState(() {
                                _activeSuit = MainViewModel.suits[0];
                              });
                            },
                          ),
                        ),
                        SizedBox(width: colGap),
                        Expanded(
                          child: _SuitTile(
                            label: _suitNames[MainViewModel.suits[1]]!,
                            color: _suitColor(MainViewModel.suits[1]),
                            icon: _suitIcon(MainViewModel.suits[1]),
                            compact: widget.isSmallScreen,
                            selected: activeSuit == MainViewModel.suits[1],
                            onLongPressStart: (details) {
                              setState(() {
                                _activeSuit = MainViewModel.suits[1];
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rowGap),
                    Row(
                      children: [
                        Expanded(
                          child: _SuitTile(
                            label: _suitNames[MainViewModel.suits[2]]!,
                            color: _suitColor(MainViewModel.suits[2]),
                            icon: _suitIcon(MainViewModel.suits[2]),
                            compact: widget.isSmallScreen,
                            selected: activeSuit == MainViewModel.suits[2],
                            onLongPressStart: (details) {
                              setState(() {
                                _activeSuit = MainViewModel.suits[2];
                              });
                            },
                          ),
                        ),
                        SizedBox(width: colGap),
                        Expanded(
                          child: _SuitTile(
                            label: _suitNames[MainViewModel.suits[3]]!,
                            color: _suitColor(MainViewModel.suits[3]),
                            icon: _suitIcon(MainViewModel.suits[3]),
                            compact: widget.isSmallScreen,
                            selected: activeSuit == MainViewModel.suits[3],
                            onLongPressStart: (details) {
                              setState(() {
                                _activeSuit = MainViewModel.suits[3];
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SuitTile extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool compact;
  final bool selected;
  final GestureLongPressStartCallback onLongPressStart;

  const _SuitTile({
    required this.label,
    required this.color,
    required this.icon,
    required this.compact,
    required this.selected,
    required this.onLongPressStart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: onLongPressStart,
      child: Container(
        height: compact ? 82 : 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.withOpacity(color, selected ? 0.35 : 0.18),
          border: Border.all(
            color: AppColors.withOpacity(color, selected ? 0.98 : 0.65),
            width: selected ? 2.2 : 1.6,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.withOpacity(color, 0.35),
                    blurRadius: 14,
                    spreadRadius: 1.5,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: compact ? 28 : 32),
            const SizedBox(height: 7),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
