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

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 720;
            final isExtraWide = constraints.maxWidth > 1100;

            if (isExtraWide) {
              return _DesktopLayout(vm: vm);
            } else if (isWide) {
              return _TabletLayout(vm: vm);
            }
            return _MobileLayout(vm: vm);
          },
        ),
      ),
    );
  }
}

// =============================================================================
// MOBILE LAYOUT
// =============================================================================
class _MobileLayout extends StatelessWidget {
  final MainViewModel vm;
  const _MobileLayout({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(vm: vm),
        const SizedBox(height: 12),
        _SelectedCardsPanel(vm: vm),
        const SizedBox(height: 12),
        _OddsDisplay(vm: vm),
        const SizedBox(height: 16),
        Expanded(child: _CardPicker(vm: vm)),
      ],
    );
  }
}

// =============================================================================
// TABLET LAYOUT
// =============================================================================
class _TabletLayout extends StatelessWidget {
  final MainViewModel vm;
  const _TabletLayout({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _Header(vm: vm, compact: true),
                const SizedBox(height: 20),
                _SelectedCardsPanel(vm: vm, expanded: true),
                const SizedBox(height: 20),
                _OddsDisplay(vm: vm, large: true),
              ],
            ),
          ),
        ),
        Container(width: 1, color: const Color(0xFFD0CBC0)),
        Expanded(
          flex: 3,
          child: _CardPicker(vm: vm),
        ),
      ],
    );
  }
}

// =============================================================================
// DESKTOP LAYOUT
// =============================================================================
class _DesktopLayout extends StatelessWidget {
  final MainViewModel vm;
  const _DesktopLayout({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: const Color(0xFFF2EFE8),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(vm: vm, compact: true),
                const SizedBox(height: 32),
                _SelectedCardsPanel(vm: vm, expanded: true, vertical: true),
                const Spacer(),
                _OddsDisplay(vm: vm, large: true),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Container(width: 1, color: const Color(0xFFD0CBC0)),
        Expanded(
          flex: 2,
          child: _CardPicker(vm: vm, gridMode: true),
        ),
      ],
    );
  }
}

// =============================================================================
// HEADER
// =============================================================================
class _Header extends StatelessWidget {
  final MainViewModel vm;
  final bool compact;

  const _Header({required this.vm, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 0 : 16, compact ? 0 : 12, compact ? 0 : 16, 0),
      child: Row(
        children: [
          if (!compact) ...[
            const Text(
              'Poker Calc',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
          ],
          _PlayersControl(vm: vm, compact: compact),
          const SizedBox(width: 8),
          _ResetButton(vm: vm),
        ],
      ),
    );
  }
}

class _PlayersControl extends StatelessWidget {
  final MainViewModel vm;
  final bool compact;

  const _PlayersControl({required this.vm, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD0CBC0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 18, color: Color(0xFF666666)),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: vm.playersNum,
              isDense: true,
              borderRadius: BorderRadius.circular(8),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D2D2D),
              ),
              items: List.generate(9, (i) => i + 2)
                  .map((n) => DropdownMenuItem(
                        value: n,
                        child: Text('$n players'),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) vm.playersNum = val;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  final MainViewModel vm;

  const _ResetButton({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: vm.reset,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD0CBC0)),
          ),
          child: const Icon(
            Icons.refresh,
            size: 20,
            color: Color(0xFFC62828),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SELECTED CARDS PANEL
// =============================================================================
class _SelectedCardsPanel extends StatelessWidget {
  final MainViewModel vm;
  final bool expanded;
  final bool vertical;

  const _SelectedCardsPanel({
    required this.vm,
    this.expanded = false,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    if (vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HandCards(vm: vm, large: true),
          const SizedBox(height: 20),
          _CommunityCards(vm: vm, large: true),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: expanded ? 0 : 16),
      child: Row(
        children: [
          Expanded(child: _HandCards(vm: vm)),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: _CommunityCards(vm: vm)),
        ],
      ),
    );
  }
}

class _HandCards extends StatelessWidget {
  final MainViewModel vm;
  final bool large;

  const _HandCards({required this.vm, this.large = false});

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: 'Your Hand',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CardSlot(
            cardId: vm.myCards.isNotEmpty ? vm.myCards[0].id : null,
            width: large ? 64 : 52,
            height: large ? 90 : 73,
          ),
          SizedBox(width: large ? 10 : 6),
          _CardSlot(
            cardId: vm.myCards.length > 1 ? vm.myCards[1].id : null,
            width: large ? 64 : 52,
            height: large ? 90 : 73,
          ),
        ],
      ),
    );
  }
}

class _CommunityCards extends StatelessWidget {
  final MainViewModel vm;
  final bool large;

  const _CommunityCards({required this.vm, this.large = false});

  @override
  Widget build(BuildContext context) {
    final cardWidth = large ? 56.0 : 44.0;
    final cardHeight = large ? 78.0 : 62.0;

    return _CardSection(
      title: 'Table',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: large ? 4 : 2),
            child: _CardSlot(
              cardId: i < vm.cardsOnTable.length ? vm.cardsOnTable[i].id : null,
              width: cardWidth,
              height: cardHeight,
            ),
          );
        }),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0DCD4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF888888),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _CardSlot extends StatelessWidget {
  final String? cardId;
  final double width;
  final double height;

  const _CardSlot({
    this.cardId,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (cardId == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3EE),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFFD0CBC0),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD0CBC0), width: 1.5),
            ),
            child: const Icon(
              Icons.add,
              size: 14,
              color: Color(0xFFBBB8B0),
            ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          imagePathConverter(cardId!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFE8E8E8),
            child: const Icon(Icons.error_outline, size: 16),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// ODDS DISPLAY
// =============================================================================
class _OddsDisplay extends StatelessWidget {
  final MainViewModel vm;
  final bool large;

  const _OddsDisplay({required this.vm, this.large = false});

  @override
  Widget build(BuildContext context) {
    final hasResult = vm.result.isNotEmpty;
    final hasCards = vm.myCards.length >= 2;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: large ? 0 : 16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: large ? 20 : 14,
        ),
        decoration: BoxDecoration(
          color: hasResult ? const Color(0xFF1B5E20) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: hasResult ? null : Border.all(color: const Color(0xFFE0DCD4)),
        ),
        child: Column(
          children: [
            Text(
              'Win Probability',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: hasResult
                    ? const Color(0xB3FFFFFF)
                    : const Color(0xFF888888),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                hasResult
                    ? vm.result
                    : hasCards
                        ? 'Calculating...'
                        : 'Select your hand',
                key: ValueKey(vm.result + hasCards.toString()),
                style: TextStyle(
                  fontSize: large ? 32 : 26,
                  fontWeight: FontWeight.w700,
                  color: hasResult
                      ? Colors.white
                      : const Color(0xFFAAAAAA),
                  letterSpacing: -1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CARD PICKER
// =============================================================================
class _CardPicker extends StatelessWidget {
  final MainViewModel vm;
  final bool gridMode;

  const _CardPicker({required this.vm, this.gridMode = false});

  @override
  Widget build(BuildContext context) {
    final suits = ['h', 'd', 'c', 's'];
    final suitSymbols = {'h': '♥', 'd': '♦', 'c': '♣', 's': '♠'};
    final suitColors = {
      'h': const Color(0xFFD32F2F),
      'd': const Color(0xFF1976D2),
      'c': const Color(0xFF388E3C),
      's': const Color(0xFF424242),
    };

    final canAddCards = vm.addCards;

    return Container(
      margin: EdgeInsets.fromLTRB(
        gridMode ? 0 : 12,
        gridMode ? 16 : 0,
        gridMode ? 16 : 12,
        gridMode ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(gridMode ? 12 : 16),
        border: Border.all(color: const Color(0xFFE0DCD4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Text(
                  'Pick a card',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const Spacer(),
                if (!canAddCards)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF558B2F),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'COMPLETE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: IgnorePointer(
              ignoring: !canAddCards,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: canAddCards ? 1.0 : 0.35,
                child: gridMode
                    ? _buildGridPicker(suits, suitSymbols, suitColors)
                    : _buildScrollPicker(suits, suitSymbols, suitColors),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollPicker(
    List<String> suits,
    Map<String, String> suitSymbols,
    Map<String, Color> suitColors,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: suits.length,
      itemBuilder: (context, index) {
        final suit = suits[index];
        final suitCards = vm.deck.where((c) => c.id.startsWith(suit)).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 6),
                child: Text(
                  suitSymbols[suit]!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: suitColors[suit],
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: suitCards.map((card) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _PickerCardTile(
                        cardId: card.id,
                        visible: card.visibility,
                        onTap: () => vm.onCardSelected(card.id),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridPicker(
    List<String> suits,
    Map<String, String> suitSymbols,
    Map<String, Color> suitColors,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: suits.map((suit) {
          final suitCards = vm.deck.where((c) => c.id.startsWith(suit)).toList();

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        suitSymbols[suit]!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: suitColors[suit],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _suitName(suit),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color.lerp(suitColors[suit], Colors.white, 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suitCards.map((card) {
                    return _PickerCardTile(
                      cardId: card.id,
                      visible: card.visibility,
                      onTap: () => vm.onCardSelected(card.id),
                      large: true,
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _suitName(String suit) {
    switch (suit) {
      case 'h':
        return 'Hearts';
      case 'd':
        return 'Diamonds';
      case 'c':
        return 'Clubs';
      case 's':
        return 'Spades';
      default:
        return '';
    }
  }
}

class _PickerCardTile extends StatelessWidget {
  final String cardId;
  final bool visible;
  final VoidCallback onTap;
  final bool large;

  const _PickerCardTile({
    required this.cardId,
    required this.visible,
    required this.onTap,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = large ? 56.0 : 46.0;
    final height = large ? 78.0 : 64.0;

    if (!visible) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFECEAE4),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              imagePathConverter(cardId),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF0F0F0),
                child: Center(
                  child: Text(
                    _cardLabel(cardId),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _cardLabel(String id) {
    final value = id.substring(1);
    switch (value) {
      case '11':
        return 'J';
      case '12':
        return 'Q';
      case '13':
        return 'K';
      case '14':
        return 'A';
      default:
        return value;
    }
  }
}
