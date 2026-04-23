import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cardModel.dart';
import '../theme/app_colors.dart';
import '../viewmodels/Mainviewmodel.dart';

String _rankLabel(String cardId) {
  final n = int.parse(cardId.substring(1));
  if (n == 14) return 'A';
  if (n == 13) return 'K';
  if (n == 12) return 'Q';
  if (n == 11) return 'J';
  return '$n';
}

class DeckPicker extends StatelessWidget {
  final MainViewModel vm;
  final bool isSmallScreen;

  const DeckPicker({super.key, required this.vm, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !vm.addCards,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: vm.addCards ? 1.0 : 0.5,
        child: Container(
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
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.withOpacity(AppColors.textSecondary, 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                child: Row(
                  children: [
                    _SuitButton(suit: 'h', symbol: '♥', color: AppColors.heartsRed, name: 'Hearts', vm: vm),
                    _SuitButton(suit: 'd', symbol: '♦', color: AppColors.diamondsRed, name: 'Diamonds', vm: vm),
                    _SuitButton(suit: 'c', symbol: '♣', color: AppColors.clubsWhite, name: 'Clubs', vm: vm),
                    _SuitButton(suit: 's', symbol: '♠', color: AppColors.spadesGray, name: 'Spades', vm: vm),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuitButton extends StatefulWidget {
  final String suit;
  final String symbol;
  final Color color;
  final String name;
  final MainViewModel vm;

  const _SuitButton({
    required this.suit,
    required this.symbol,
    required this.color,
    required this.name,
    required this.vm,
  });

  @override
  State<_SuitButton> createState() => _SuitButtonState();
}

class _SuitButtonState extends State<_SuitButton> {
  OverlayEntry? _overlay;
  final ValueNotifier<int?> _hovered = ValueNotifier(null);
  late List<CardModel> _cards;
  // clamped center passed to both ring overlay and nearest-index computation
  Offset? _ringCenter;

  static const double _ringRadius = 120.0;

  @override
  void initState() {
    super.initState();
    _refreshCards();
  }

  @override
  void didUpdateWidget(_SuitButton old) {
    super.didUpdateWidget(old);
    if (old.vm != widget.vm || old.suit != widget.suit) {
      _refreshCards();
    }
  }

  void _refreshCards() {
    _cards = widget.vm.deck
        .where((c) => c.id.startsWith(widget.suit))
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
  }

  @override
  void dispose() {
    _removeOverlay();
    _hovered.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
    _hovered.value = null;
  }

  void _showOverlay() {
    HapticFeedback.mediumImpact();

    final box = context.findRenderObject() as RenderBox;
    final rawCenter = box.localToGlobal(
      Offset(box.size.width / 2, box.size.height / 2),
    );
    final sw = MediaQuery.of(context).size.width;
    // clamp so ring stays within screen horizontally
    _ringCenter = Offset(
      rawCenter.dx.clamp(_ringRadius, sw - _ringRadius),
      rawCenter.dy,
    );

    _overlay = OverlayEntry(
      builder: (_) => _RingOverlay(
        center: _ringCenter!,
        cards: _cards,
        color: widget.color,
        hovered: _hovered,
        onDismiss: () {
          _removeOverlay();
          if (mounted) setState(() {});
        },
      ),
    );
    Overlay.of(context).insert(_overlay!);
    setState(() {});
  }

  int? _nearestIndex(Offset pos) {
    if (_ringCenter == null) return null;
    const snap = 52.0;
    double best = double.infinity;
    int? idx;
    for (int i = 0; i < _cards.length; i++) {
      final angle = pi + (i / (_cards.length - 1)) * pi;
      final itemPos = Offset(
        _ringCenter!.dx + _ringRadius * cos(angle),
        _ringCenter!.dy + _ringRadius * sin(angle),
      );
      final d = (pos - itemPos).distance;
      if (d < best) {
        best = d;
        idx = i;
      }
    }
    return best < snap ? idx : null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _cards.where((c) => !c.visibility).length;
    final isOpen = _overlay != null;
    final allUsed = selectedCount == 13;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (_) => _showOverlay(),
        onLongPressMoveUpdate: (d) {
          if (_overlay != null) {
            _hovered.value = _nearestIndex(d.globalPosition);
          }
        },
        onLongPressEnd: (d) {
          if (_overlay != null) {
            final idx = _hovered.value ?? _nearestIndex(d.globalPosition);
            if (idx != null && _cards[idx].visibility) {
              HapticFeedback.lightImpact();
              widget.vm.onCardSelected(_cards[idx].id);
            }
            _removeOverlay();
            setState(() {});
          }
        },
        onLongPressCancel: () {
          _removeOverlay();
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: isOpen
                ? AppColors.withOpacity(widget.color, 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.withOpacity(widget.color, isOpen ? 0.8 : 0.3),
              width: isOpen ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.symbol,
                style: TextStyle(
                  fontSize: 34,
                  color: allUsed
                      ? AppColors.withOpacity(widget.color, 0.3)
                      : widget.color,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              if (selectedCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.withOpacity(widget.color, 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$selectedCount/13',
                    style: TextStyle(
                      fontSize: 9,
                      color: widget.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.withOpacity(AppColors.textSecondary, 0.6),
                    letterSpacing: 0.3,
                  ),
                ),
              const SizedBox(height: 3),
              Text(
                'hold',
                style: TextStyle(
                  fontSize: 8,
                  color: AppColors.withOpacity(AppColors.textSecondary, 0.35),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingOverlay extends StatelessWidget {
  final Offset center;
  final List<CardModel> cards;
  final Color color;
  final ValueNotifier<int?> hovered;
  final VoidCallback onDismiss;

  const _RingOverlay({
    required this.center,
    required this.cards,
    required this.color,
    required this.hovered,
    required this.onDismiss,
  });

  static const double _r = 120;
  static const double _sz = 34;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: Container(color: Colors.black54),
            ),
          ),
          for (int i = 0; i < cards.length; i++)
            ValueListenableBuilder<int?>(
              valueListenable: hovered,
              builder: (_, h, __) {
                final angle = pi + (i / (cards.length - 1)) * pi;
                final px = center.dx + _r * cos(angle);
                final py = center.dy + _r * sin(angle);
                final isH = h == i;
                final avail = cards[i].visibility;
                final s = isH ? _sz * 1.35 : _sz;

                return Positioned(
                  left: px - s / 2,
                  top: py - s / 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    width: s,
                    height: s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: avail
                          ? (isH ? color : AppColors.withOpacity(color, 0.18))
                          : AppColors.surfaceLight,
                      border: Border.all(
                        color: avail
                            ? AppColors.withOpacity(color, isH ? 1.0 : 0.45)
                            : Colors.transparent,
                        width: isH ? 2.0 : 1.0,
                      ),
                      boxShadow: isH && avail
                          ? [
                              BoxShadow(
                                color: AppColors.withOpacity(color, 0.55),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        avail ? _rankLabel(cards[i].id) : '✓',
                        style: TextStyle(
                          fontSize: isH ? 13 : 11,
                          fontWeight: FontWeight.bold,
                          color: avail
                              ? (isH
                                  ? Colors.white
                                  : AppColors.withOpacity(Colors.white, 0.85))
                              : AppColors.withOpacity(
                                  AppColors.textSecondary, 0.45),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
