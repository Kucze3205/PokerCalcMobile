import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../viewmodels/Mainviewmodel.dart';
import 'card_slot.dart';
import 'section_container.dart';

class TableSection extends StatelessWidget {
  final MainViewModel vm;
  final bool isSmallScreen;

  const TableSection({super.key, required this.vm, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'COMMUNITY CARDS',
      icon: Icons.table_restaurant,
      iconColor: AppColors.accent,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            String label = '';
            if (index < 3) {
              label = 'Flop';
            } else if (index == 3) {
              label = 'Turn';
            } else {
              label = 'River';
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CardSlot(
                card: vm.cardsOnTable.length > index
                    ? vm.cardsOnTable[index]
                    : null,
                isSmallScreen: isSmallScreen,
                label: label,
                isTable: true,
                onTap: vm.cardsOnTable.length > index
                    ? () => vm.removeCard(vm.cardsOnTable[index].id)
                    : null,
              ),
            );
          }),
        ),
      ),
    );
  }
}
