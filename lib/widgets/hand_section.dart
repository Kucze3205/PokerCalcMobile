import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../viewmodels/Mainviewmodel.dart';
import 'card_slot.dart';
import 'result_section.dart';
import 'section_container.dart';

class HandSection extends StatelessWidget {
  final MainViewModel vm;
  final bool isSmallScreen;

  const HandSection({super.key, required this.vm, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'YOUR HAND',
      icon: Icons.back_hand,
      iconColor: AppColors.accentGold,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final handRow = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CardSlot(
                card: vm.myCards.isNotEmpty ? vm.myCards[0] : null,
                isSmallScreen: isSmallScreen,
                label: '1',
                onTap: vm.myCards.isNotEmpty
                    ? () => vm.removeCard(vm.myCards[0].id)
                    : null,
              ),
              const SizedBox(width: 16),
              CardSlot(
                card: vm.myCards.length > 1 ? vm.myCards[1] : null,
                isSmallScreen: isSmallScreen,
                label: '2',
                onTap: vm.myCards.length > 1
                    ? () => vm.removeCard(vm.myCards[1].id)
                    : null,
              ),
            ],
          );

          final winProbability = ResultSection(vm: vm, embedded: true);
          final isNarrow = constraints.maxWidth < 420;

          if (isNarrow) {
            return Column(
              children: [handRow, const SizedBox(height: 16), winProbability],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Align(alignment: Alignment.topCenter, child: handRow),
              ),
              const SizedBox(width: 16),
              Expanded(child: winProbability),
            ],
          );
        },
      ),
    );
  }
}
