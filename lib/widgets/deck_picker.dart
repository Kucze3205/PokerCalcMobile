import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../converter/imagepathconverter.dart';
import '../theme/app_colors.dart';
import '../viewmodels/Mainviewmodel.dart';

class DeckPicker extends StatelessWidget {
  final MainViewModel vm;
  final bool isSmallScreen;

  const DeckPicker({super.key, required this.vm, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    const suits = ['h', 'd', 'c', 's'];
    final suitColors = {
      'h': AppColors.hearts,
      'd': AppColors.diamonds,
      'c': AppColors.clubs,
      's': AppColors.spades,
    };
    final double deckCardSize = isSmallScreen ? 26 : 34;

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
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.withOpacity(AppColors.textSecondary, 0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Card grid by suit
          IgnorePointer(
            ignoring: !vm.addCards,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: vm.addCards ? 1.0 : 0.75,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
                child: Column(
                  children: suits.map((suit) {
                    final suitCards =
                        vm.deck.where((c) => c.id.startsWith(suit)).toList();
                    final suitColor = suitColors[suit]!;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: suitCards.map((card) {
                                return _DeckCard(
                                  card: card,
                                  vm: vm,
                                  suitColor: suitColor,
                                  size: deckCardSize,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final dynamic card;
  final MainViewModel vm;
  final Color suitColor;
  final double size;

  const _DeckCard({
    required this.card,
    required this.vm,
    required this.suitColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final bool isVisible = card.visibility;

    return GestureDetector(
      onTap: isVisible ? () => vm.onCardSelected(card.id) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size * 1.35,
        decoration: BoxDecoration(
          color: isVisible ? Colors.white : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isVisible
                ? AppColors.withOpacity(suitColor, 0.5)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: isVisible
              ? [
                  BoxShadow(
                    color: AppColors.withOpacity(suitColor, 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isVisible
            ? ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SvgPicture.asset(
                  imagePathConverter(card.id),
                  fit: BoxFit.contain,
                ),
              )
            : Center(
                child: Icon(
                  Icons.check,
                  color: AppColors.withOpacity(AppColors.accent, 0.5),
                  size: size * 0.5,
                ),
              ),
      ),
    );
  }
}
