import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    'h': 'Hearts',
    'd': 'Diamonds',
    'c': 'Clubs',
    's': 'Spades',
  };

  String? _activeSuit;
  int? _activeRankIndex;
  String? _pendingSuit;
  Timer? _longPressTimer;

  // Set in LayoutBuilder so pointer handlers can compute centers
  double _tileWidth = 0;

  double get _tileHeight => widget.isSmallScreen ? 82.0 : 96.0;
  double get _rowGap => widget.isSmallScreen ? 10.0 : 12.0;
  double get _colGap => widget.isSmallScreen ? 10.0 : 12.0;
  double get _ringRadius => widget.isSmallScreen ? 92.0 : 110.0;
  double get _itemSize => widget.isSmallScreen ? 42.0 : 48.0;
  double get _innerRadius => widget.isSmallScreen ? 56.0 : 68.0;
  double get _outerRadius => _ringRadius + _itemSize * 0.8;

  // Fixed top offset — always reserves space for the ring above row-0 tiles.
  // Keeping this constant avoids layout shifts when a suit activates.
  double get _gridTop => math.max(0.0, _outerRadius - _tileHeight / 2 + 12);

  Offset _tileCenter(String suit) {
    final index = MainViewModel.suits.indexOf(suit);
    final col = index % 2;
    final row = index ~/ 2;
    return Offset(
      col * (_tileWidth + _colGap) + _tileWidth / 2,
      _gridTop + row * (_tileHeight + _rowGap) + _tileHeight / 2,
    );
  }

  String? _hitTestSuit(Offset pos) {
    for (final suit in MainViewModel.suits) {
      final c = _tileCenter(suit);
      if ((pos.dx - c.dx).abs() < _tileWidth / 2 &&
          (pos.dy - c.dy).abs() < _tileHeight / 2) {
        return suit;
      }
    }
    return null;
  }

  int? _rankIndexFromOffset(Offset pos, Offset center) {
    final dx = pos.dx - center.dx;
    final dy = pos.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < _innerRadius || dist > _outerRadius) return null;
    final angle = math.atan2(dy, dx);
    final normalized = angle < 0 ? angle + 2 * math.pi : angle;
    final shifted = (normalized + math.pi / 2) % (2 * math.pi);
    final step = (2 * math.pi) / MainViewModel.ranks.length;
    return (shifted / step).round() % MainViewModel.ranks.length;
  }

  void _onPointerDown(PointerDownEvent event) {
    final suit = _hitTestSuit(event.localPosition);
    if (suit == null) return;
    setState(() => _pendingSuit = suit);
    _longPressTimer?.cancel();
    _longPressTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() {
        _activeSuit = _pendingSuit;
        _pendingSuit = null;
      });
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    final suit = _activeSuit;
    if (suit == null) return;
    final newIndex = _rankIndexFromOffset(event.localPosition, _tileCenter(suit));
    if (newIndex != _activeRankIndex) {
      if (newIndex != null) HapticFeedback.selectionClick();
      setState(() => _activeRankIndex = newIndex);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    final suit = _activeSuit;
    if (suit == null) {
      setState(() => _pendingSuit = null);
      return;
    }
    final index = _activeRankIndex;
    setState(() {
      _activeSuit = null;
      _activeRankIndex = null;
      _pendingSuit = null;
    });
    if (index == null) return;
    final rank = MainViewModel.ranks[index];
    if (!widget.vm.isCardAvailable(suit, rank)) return;
    widget.vm.onCardSelected('$suit$rank');
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    setState(() {
      _activeSuit = null;
      _activeRankIndex = null;
      _pendingSuit = null;
    });
  }

  Color _suitColor(String suit) {
    switch (suit) {
      case 'h': return AppColors.hearts;
      case 'd': return AppColors.diamonds;
      case 'c': return AppColors.clubs;
      case 's': return AppColors.spades;
      default: return AppColors.accent;
    }
  }

  IconData _suitIcon(String suit) {
    switch (suit) {
      case 'h': return Icons.favorite;
      case 'd': return Icons.change_history;
      case 'c': return Icons.filter_vintage;
      case 's': return Icons.navigation;
      default: return Icons.casino;
    }
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
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
                child: _buildSuitSelector(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuitSelector() {
    final totalHeight = _tileHeight * 2 + _rowGap + _gridTop;

    return LayoutBuilder(
      builder: (context, constraints) {
        _tileWidth = (constraints.maxWidth - _colGap) / 2;

        return Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: SizedBox(
            width: constraints.maxWidth,
            height: totalHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (_activeSuit != null) _buildRing(_activeSuit!),
                Positioned(
                  left: 0,
                  right: 0,
                  top: _gridTop,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildSuitTile(MainViewModel.suits[0])),
                          SizedBox(width: _colGap),
                          Expanded(child: _buildSuitTile(MainViewModel.suits[1])),
                        ],
                      ),
                      SizedBox(height: _rowGap),
                      Row(
                        children: [
                          Expanded(child: _buildSuitTile(MainViewModel.suits[2])),
                          SizedBox(width: _colGap),
                          Expanded(child: _buildSuitTile(MainViewModel.suits[3])),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRing(String suit) {
    final center = _tileCenter(suit);
    final color = _suitColor(suit);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: center.dx - _ringRadius,
          top: center.dy - _ringRadius,
          child: Container(
            width: _ringRadius * 2,
            height: _ringRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.withOpacity(color, 0.5),
                width: 2.5,
              ),
            ),
          ),
        ),
        ...List.generate(MainViewModel.ranks.length, (i) {
          final rank = MainViewModel.ranks[i];
          final angle = -math.pi / 2 + 2 * math.pi * i / MainViewModel.ranks.length;
          final x = center.dx + math.cos(angle) * _ringRadius - _itemSize / 2;
          final y = center.dy + math.sin(angle) * _ringRadius - _itemSize / 2;
          final available = widget.vm.isCardAvailable(suit, rank);
          final isActive = _activeRankIndex == i;

          return Positioned(
            left: x,
            top: y,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: _itemSize,
              height: _itemSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !available
                    ? AppColors.surfaceLight
                    : isActive
                        ? color
                        : AppColors.withOpacity(color, 0.2),
                border: Border.all(
                  color: available
                      ? AppColors.withOpacity(color, isActive ? 1.0 : 0.7)
                      : AppColors.withOpacity(AppColors.textSecondary, 0.2),
                  width: isActive ? 2.2 : 1.3,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.withOpacity(color, 0.4),
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
                        ? AppColors.withOpacity(AppColors.textSecondary, 0.4)
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
    );
  }

  Widget _buildSuitTile(String suit) {
    final active = _activeSuit == suit || _pendingSuit == suit;
    final color = _suitColor(suit);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: _tileHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.withOpacity(color, active ? 0.35 : 0.18),
        border: Border.all(
          color: AppColors.withOpacity(color, active ? 0.98 : 0.65),
          width: active ? 2.2 : 1.6,
        ),
        boxShadow: active
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
          Icon(_suitIcon(suit), color: color, size: widget.isSmallScreen ? 28 : 32),
          const SizedBox(height: 7),
          Text(
            _suitNames[suit]!,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: widget.isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
