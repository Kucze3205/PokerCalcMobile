// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/Mainviewmodel.dart';
import '../converter/imagepathconverter.dart';

final mainViewModelProvider = ChangeNotifierProvider((ref) => MainViewModel());

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(mainViewModelProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: isLandscape
            ? _buildLandscapeLayout(context, vm, theme)
            : _buildPortraitLayout(context, vm, theme),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, MainViewModel vm, ThemeData theme) {
    return Column(
      children: [
        _buildHeader(context, vm, theme),
        const SizedBox(height: 16),
        _buildCardsSection(context, vm, theme),
        const SizedBox(height: 16),
        _buildResultSection(context, vm, theme),
        const SizedBox(height: 16),
        Expanded(child: _buildCardPicker(context, vm, theme)),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, MainViewModel vm, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildHeader(context, vm, theme),
              const SizedBox(height: 12),
              _buildCardsSection(context, vm, theme),
              const SizedBox(height: 12),
              _buildResultSection(context, vm, theme),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: _buildCardPicker(context, vm, theme),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, MainViewModel vm, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Row(
        children: [
          Text(
            'Poker Calc',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          _buildPlayersSelector(context, vm, theme),
          const SizedBox(width: 8),
          _buildResetButton(context, vm, theme),
        ],
      ),
    );
  }

  Widget _buildPlayersSelector(BuildContext context, MainViewModel vm, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: vm.playersNum,
            underline: const SizedBox(),
            isDense: true,
            borderRadius: BorderRadius.circular(12),
            items: List.generate(9, (i) => i + 2)
                .map((n) => DropdownMenuItem(
                      value: n,
                      child: Text(
                        '$n',
                        style: theme.textTheme.titleMedium,
                      ),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) vm.playersNum = val;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, MainViewModel vm, ThemeData theme) {
    return IconButton.filled(
      onPressed: vm.reset,
      icon: const Icon(Icons.refresh_rounded),
      style: IconButton.styleFrom(
        backgroundColor: theme.colorScheme.errorContainer,
        foregroundColor: theme.colorScheme.onErrorContainer,
      ),
      tooltip: 'Reset',
    );
  }

  Widget _buildCardsSection(BuildContext context, MainViewModel vm, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildHandSection(context, vm, theme)),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: _buildTableSection(context, vm, theme)),
        ],
      ),
    );
  }

  Widget _buildHandSection(BuildContext context, MainViewModel vm, ThemeData theme) {
    return _CardContainer(
      label: 'Your Hand',
      theme: theme,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCardSlot(vm.myCards.isNotEmpty ? vm.myCards[0].id : null, theme),
          const SizedBox(width: 8),
          _buildCardSlot(vm.myCards.length > 1 ? vm.myCards[1].id : null, theme),
        ],
      ),
    );
  }

  Widget _buildTableSection(BuildContext context, MainViewModel vm, ThemeData theme) {
    return _CardContainer(
      label: 'Community Cards',
      theme: theme,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final card = index < vm.cardsOnTable.length ? vm.cardsOnTable[index].id : null;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildCardSlot(card, theme, small: true),
          );
        }),
      ),
    );
  }

  Widget _buildCardSlot(String? cardId, ThemeData theme, {bool small = false}) {
    final width = small ? 44.0 : 56.0;
    final height = small ? 64.0 : 80.0;

    if (cardId == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Icon(
          Icons.add_rounded,
          color: theme.colorScheme.outlineVariant,
          size: small ? 20 : 24,
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePathConverter(cardId),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: theme.colorScheme.errorContainer,
            child: Icon(Icons.error, color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection(BuildContext context, MainViewModel vm, ThemeData theme) {
    final hasResult = vm.result.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: hasResult
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withOpacity(0.7),
                  ],
                )
              : null,
          color: hasResult ? null : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasResult ? Icons.analytics_outlined : Icons.hourglass_empty_rounded,
              color: hasResult
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Win + Draw',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: hasResult
                        ? theme.colorScheme.onPrimaryContainer.withOpacity(0.7)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    hasResult ? vm.result : 'Select cards...',
                    key: ValueKey(vm.result),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasResult
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPicker(BuildContext context, MainViewModel vm, ThemeData theme) {
    final suits = ['h', 'd', 'c', 's'];
    final suitColors = {
      'h': Colors.red.shade600,
      'd': Colors.blue.shade600,
      'c': Colors.green.shade700,
      's': Colors.grey.shade800,
    };
    final suitIcons = {
      'h': '♥',
      'd': '♦',
      'c': '♣',
      's': '♠',
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  'Select a Card',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (!vm.addCards)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'All cards selected',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: IgnorePointer(
              ignoring: !vm.addCards,
              child: Opacity(
                opacity: vm.addCards ? 1.0 : 0.4,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: suits.length,
                  itemBuilder: (context, suitIndex) {
                    final suit = suits[suitIndex];
                    final suitCards = vm.deck
                        .where((c) => c.id.startsWith(suit))
                        .toList();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 6),
                            child: Text(
                              suitIcons[suit]!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: suitColors[suit],
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: suitCards.map((card) {
                                if (!card.visibility) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Container(
                                      width: 48,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: _PickerCard(
                                    cardId: card.id,
                                    onTap: () => vm.onCardSelected(card.id),
                                    theme: theme,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final String label;
  final Widget child;
  final ThemeData theme;

  const _CardContainer({
    required this.label,
    required this.child,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _PickerCard extends StatelessWidget {
  final String cardId;
  final VoidCallback onTap;
  final ThemeData theme;

  const _PickerCard({
    required this.cardId,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePathConverter(cardId),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: theme.colorScheme.errorContainer,
                child: const Icon(Icons.error, size: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}