import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../converter/imagepathconverter.dart';
import '../theme/app_colors.dart';

class CardSlot extends StatelessWidget {
  final dynamic card;
  final bool isSmallScreen;
  final String label;
  final bool isTable;
  final VoidCallback? onTap;

  const CardSlot({
    super.key,
    required this.card,
    required this.isSmallScreen,
    required this.label,
    this.isTable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double cardWidth = isSmallScreen
        ? (isTable ? 48 : 65)
        : (isTable ? 60 : 80);
    final double cardHeight = cardWidth * 1.4;

    final slot = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: card != null ? Colors.transparent : AppColors.cardSlot,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: card != null
              ? AppColors.withOpacity(AppColors.accent, 0.5)
              : AppColors.surfaceLight,
          width: card != null ? 2 : 1,
        ),
        boxShadow: card != null
            ? [
                BoxShadow(
                  color: AppColors.withOpacity(AppColors.accent, 0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: card != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SvgPicture.asset(
                imagePathConverter(card.id),
                fit: BoxFit.contain,
              ),
            )
          : Center(
              child: Icon(
                Icons.add_rounded,
                color: AppColors.withOpacity(AppColors.textSecondary, 0.3),
                size: cardWidth * 0.4,
              ),
            ),
    );

    final slotWithTap = (card != null && onTap != null)
        ? GestureDetector(onTap: onTap, child: slot)
        : slot;

    return Column(
      children: [
        slotWithTap,
        if (!isTable) ...[
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.withOpacity(AppColors.textSecondary, 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
