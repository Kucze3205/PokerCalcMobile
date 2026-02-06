// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../converter/imagepathconverter.dart';
import '../models/cardModel.dart';
import '../viewmodels/Mainviewmodel.dart';

// Provider dla MainViewModel (Riverpod)
final mainViewModelProvider = ChangeNotifierProvider((ref) => MainViewModel());

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(mainViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFDF9F2), Color(0xFFEAF3FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= 900;
              final double cardWidth = isWide ? 96 : 72;
              final double cardHeight = cardWidth * 1.4;
              final int deckCrossAxisCount = isWide ? 13 : 6;

              final Widget cardsStrip = isWide
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildCardRail(
                            context: context,
                            label: 'Your hand',
                            cards: vm.myCards,
                            slotCount: 2,
                            cardWidth: cardWidth,
                            cardHeight: cardHeight,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildCardRail(
                            context: context,
                            label: 'Table cards',
                            cards: vm.cardsOnTable,
                            slotCount: 5,
                            cardWidth: cardWidth,
                            cardHeight: cardHeight,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildCardRail(
                          context: context,
                          label: 'Your hand',
                          cards: vm.myCards,
                          slotCount: 2,
                          cardWidth: cardWidth,
                          cardHeight: cardHeight,
                        ),
                        const SizedBox(height: 20),
                        _buildCardRail(
                          context: context,
                          label: 'Table cards',
                          cards: vm.cardsOnTable,
                          slotCount: 5,
                          cardWidth: cardWidth,
                          cardHeight: cardHeight,
                        ),
                      ],
                    );

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context, vm),
                        const SizedBox(height: 20),
                        cardsStrip,
                        const SizedBox(height: 20),
                        _buildStatusPanel(context, vm),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildDeckSection(
                            context: context,
                            vm: vm,
                            crossAxisCount: deckCrossAxisCount,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MainViewModel vm) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PokerCalc Studio',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Colors.blueGrey.shade900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lightweight odds tracking for any table size.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.blueGrey.shade500,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: vm.reset,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reset run'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            foregroundColor: Colors.blueGrey.shade700,
            side: BorderSide(color: Colors.blueGrey.shade100),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  Widget _buildCardRail({
    required BuildContext context,
    required String label,
    required List<CardModel> cards,
    required int slotCount,
    required double cardWidth,
    required double cardHeight,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade700,
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(slotCount, (index) {
                final cardId = index < cards.length ? cards[index].id : null;
                return Padding(
                  padding: EdgeInsets.only(right: index == slotCount - 1 ? 0 : 14),
                  child: _cardSlot(cardId, cardWidth, cardHeight),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardSlot(String? cardId, double width, double height) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.7)),
        color: cardId == null ? Colors.white.withOpacity(0.35) : Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: cardId == null
          ? Icon(
              Icons.add,
              color: Colors.blueGrey.shade200,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SvgPicture.asset(
                imagePathConverter(cardId),
                fit: BoxFit.cover,
                placeholderBuilder: (context) => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
              ),
            ),
    );
  }

  Widget _buildStatusPanel(BuildContext context, MainViewModel vm) {
    final textTheme = Theme.of(context).textTheme;
    final resultText = vm.result.isEmpty ? '--.--%' : vm.result;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: _panelDecoration(),
      child: Wrap(
        runSpacing: 18,
        spacing: 24,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Win + draw chance',
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.blueGrey.shade600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                resultText,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey.shade900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                vm.addCards ? 'Select cards to simulate odds.' : 'Deck locked. Reset to start over.',
                style: textTheme.bodySmall?.copyWith(color: Colors.blueGrey.shade400),
              ),
            ],
          ),
          _buildPlayersSelector(context, vm),
        ],
      ),
    );
  }

  Widget _buildPlayersSelector(BuildContext context, MainViewModel vm) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.shade50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Players in hand',
                style: textTheme.labelMedium?.copyWith(color: Colors.blueGrey.shade500),
              ),
              Text(
                '${vm.playersNum} active',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(width: 12),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: vm.playersNum,
              items: List.generate(9, (index) => index + 2)
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text('$value'),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  vm.updatePlayersNum(value);
                }
              },
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckSection({
    required BuildContext context,
    required MainViewModel vm,
    required int crossAxisCount,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deck builder',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                  Text(
                    vm.addCards ? 'Tap any card to add it.' : 'Maximum cards placed.',
                    style: textTheme.bodySmall?.copyWith(color: Colors.blueGrey.shade400),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: vm.addCards ? const Color(0xFFDCF8C6) : const Color(0xFFFFE0E0),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  vm.addCards ? 'Select cards' : 'Locked',
                  style: textTheme.labelSmall?.copyWith(
                    color: vm.addCards ? const Color(0xFF0F6B28) : const Color(0xFF944040),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 240),
              opacity: vm.addCards ? 1 : 0.35,
              child: IgnorePointer(
                ignoring: !vm.addCards,
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: vm.deck.length,
                  itemBuilder: (context, index) {
                    final card = vm.deck[index];
                    if (!card.visibility) {
                      return const SizedBox.shrink();
                    }
                    return GestureDetector(
                      onTap: () => vm.onCardSelected(card.id),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x13000000),
                              blurRadius: 10,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SvgPicture.asset(
                            imagePathConverter(card.id),
                            fit: BoxFit.cover,
                            placeholderBuilder: (context) => const ColoredBox(
                              color: Color(0x11000000),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                            ),
                          ),
                        ),
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

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.88),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white.withOpacity(0.3)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 24,
          offset: Offset(0, 12),
        ),
      ],
    );
  }
}