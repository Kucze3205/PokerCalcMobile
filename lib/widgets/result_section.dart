import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../viewmodels/Mainviewmodel.dart';

class ResultSection extends StatelessWidget {
  final MainViewModel vm;
  final bool embedded;

  const ResultSection({super.key, required this.vm, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final hasResult = vm.result.isNotEmpty;
    final isCalculating = vm.myCards.length == 2 && vm.result.isEmpty;

    final content = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasResult ? Icons.analytics : Icons.calculate_outlined,
              color: hasResult ? AppColors.accent : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'WIN PROBABILITY',
              style: TextStyle(
                color: hasResult ? AppColors.accent : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isCalculating)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.withOpacity(AppColors.accent, 0.7),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Calculating...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
              ),
            ],
          )
        else if (hasResult)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (value.clamp(0.0, 1.0) * 0.5),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Text(
                    vm.result,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              );
            },
          )
        else
          Text(
            'Select your cards',
            style: TextStyle(
              color: AppColors.withOpacity(AppColors.textSecondary, 0.6),
              fontSize: 16,
            ),
          ),
        if (hasResult) ...[
          const SizedBox(height: 8),
          Text(
            '(win + draw)',
            style: TextStyle(
              color: AppColors.withOpacity(AppColors.textSecondary, 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );

    if (embedded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: content,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: hasResult
            ? LinearGradient(
                colors: [
                  AppColors.withOpacity(AppColors.accent, 0.15),
                  AppColors.withOpacity(AppColors.accentGold, 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hasResult ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasResult
              ? AppColors.withOpacity(AppColors.accent, 0.4)
              : AppColors.surfaceLight,
          width: hasResult ? 2 : 1,
        ),
        boxShadow: hasResult
            ? [
                BoxShadow(
                  color: AppColors.withOpacity(AppColors.accent, 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: content,
    );
  }
}
