// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../viewmodels/Mainviewmodel.dart';
import '../widgets/deck_picker.dart';
import '../widgets/hand_section.dart';
import '../widgets/main_header.dart';
import '../widgets/table_section.dart';

// Provider dla MainViewModel (Riverpod)
final mainViewModelProvider = ChangeNotifierProvider((ref) => MainViewModel());

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(mainViewModelProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            MainHeader(vm: vm),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Your hand + win probability (single section)
                    HandSection(vm: vm, isSmallScreen: isSmallScreen),

                    const SizedBox(height: 20),

                    // Table cards section
                    TableSection(vm: vm, isSmallScreen: isSmallScreen),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Card deck picker
            DeckPicker(vm: vm, isSmallScreen: isSmallScreen),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD

  Widget _buildHeader(MainViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo/Title
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentGold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.casino,
                    color: AppColors.background,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'Poker Calc',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Players selector
          _buildPlayersSelector(vm),
          
          const SizedBox(width: 8),
          
          // Reset button
          _buildResetButton(vm),
        ],
      ),
    );
  }

  Widget _buildPlayersSelector(MainViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.people,
            color: AppColors.accent,
            size: 18,
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: vm.playersNum,
              dropdownColor: AppColors.surface,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.accent,
              ),
              items: List.generate(9, (i) => i + 2)
                  .map((n) => DropdownMenuItem(
                        value: n,
                        child: Text('$n'),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  vm.playersNum = val;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(MainViewModel vm) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: vm.reset,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: const Icon(
            Icons.refresh_rounded,
            color: Colors.redAccent,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildHandSection(MainViewModel vm, bool isSmallScreen) {
    return _buildSection(
      title: 'YOUR HAND',
      icon: Icons.back_hand,
      iconColor: AppColors.accentGold,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCardSlot(
            card: vm.myCards.isNotEmpty ? vm.myCards[0] : null,
            isSmallScreen: isSmallScreen,
            label: '1',
          ),
          const SizedBox(width: 16),
          _buildCardSlot(
            card: vm.myCards.length > 1 ? vm.myCards[1] : null,
            isSmallScreen: isSmallScreen,
            label: '2',
          ),
        ],
      ),
    );
  }

  Widget _buildTableSection(MainViewModel vm, bool isSmallScreen) {
    return _buildSection(
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
            } else if (index == 3) label = 'Turn';
            else label = 'River';
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildCardSlot(
                card: vm.cardsOnTable.length > index ? vm.cardsOnTable[index] : null,
                isSmallScreen: isSmallScreen,
                label: label,
                isTable: true,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildCardSlot({
    dynamic card,
    required bool isSmallScreen,
    required String label,
    bool isTable = false,
  }) {
    final double cardWidth = isSmallScreen ? (isTable ? 48 : 65) : (isTable ? 60 : 80);
    final double cardHeight = cardWidth * 1.4;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: card != null ? Colors.transparent : AppColors.cardSlot,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: card != null 
                  ? AppColors.accent.withOpacity(0.5) 
                  : AppColors.surfaceLight,
              width: card != null ? 2 : 1,
            ),
            boxShadow: card != null
                ? [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3),
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
                    color: AppColors.textSecondary.withOpacity(0.3),
                    size: cardWidth * 0.4,
                  ),
                ),
        ),
        if (!isTable) ...[
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultSection(MainViewModel vm) {
    final hasResult = vm.result.isNotEmpty;
    final isCalculating = vm.myCards.length == 2 && vm.result.isEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: hasResult
            ? LinearGradient(
                colors: [
                  AppColors.accent.withOpacity(0.15),
                  AppColors.accentGold.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hasResult ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasResult 
              ? AppColors.accent.withOpacity(0.4) 
              : AppColors.surfaceLight,
          width: hasResult ? 2 : 1,
        ),
        boxShadow: hasResult
            ? [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
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
                      AppColors.accent.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Calculating...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                  ),
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
                color: AppColors.textSecondary.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          if (hasResult) ...[
            const SizedBox(height: 8),
            Text(
              '(win + draw)',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeckPicker(MainViewModel vm, bool isSmallScreen) {
    final suits = ['h', 'd', 'c', 's'];
    final suitColors = {
      'h': AppColors.hearts,
      'd': AppColors.diamonds,
      'c': AppColors.clubs,
      's': AppColors.spades,
    };
    final suitIcons = {
      'h': '♥',
      'd': '♦',
      'c': '♣',
      's': '♠',
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Deck hint
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              vm.addCards ? 'TAP A CARD TO SELECT' : 'ALL CARDS SELECTED',
              style: TextStyle(
                color: vm.addCards 
                    ? AppColors.accent 
                    : AppColors.textSecondary.withOpacity(0.5),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          // Card grid by suit
          IgnorePointer(
            ignoring: !vm.addCards,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: vm.addCards ? 1.0 : 0.4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Column(
                  children: suits.map((suit) {
                    final suitCards = vm.deck.where((c) => c.id.startsWith(suit)).toList();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          // Suit indicator
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: suitColors[suit]!.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                suitIcons[suit]!,
                                style: TextStyle(
                                  color: suitColors[suit],
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Cards row
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: suitCards.map((card) {
                                return _buildDeckCard(
                                  card: card,
                                  vm: vm,
                                  suitColor: suitColors[suit]!,
                                  isSmallScreen: isSmallScreen,
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

  Widget _buildDeckCard({
    required dynamic card,
    required MainViewModel vm,
    required Color suitColor,
    required bool isSmallScreen,
  }) {
    final bool isVisible = card.visibility;
    final double size = isSmallScreen ? 22 : 28;

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
            color: isVisible ? suitColor.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
          boxShadow: isVisible
              ? [
                  BoxShadow(
                    color: suitColor.withOpacity(0.3),
                    blurRadius: 4,
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
                  color: AppColors.accent.withOpacity(0.5),
                  size: size * 0.5,
                ),
              ),
      ),
    );
  }
}
=======
}
>>>>>>> 266db046806ad24640318b4e513edbf56017cbd5
