// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/Mainviewmodel.dart';
import '../converter/imagepathconverter.dart';

// Provider dla MainViewModel (Riverpod)
final mainViewModelProvider = ChangeNotifierProvider((ref) => MainViewModel());

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(mainViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Poker Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Nagłówki
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Your hand', style: TextStyle(fontSize: 32)),
                Text('Table', style: TextStyle(fontSize: 32)),
              ],
            ),
            const SizedBox(height: 10),
            // Twoje karty i karty na stole
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Twoje karty
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: vm.myCards.map((card) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Image.asset(
                        imagePathConverter(card.id),
                        width: 60,
                        height: 90,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      ),
                    )).toList(),
                  ),
                ),
                // Karty na stole
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: vm.cardsOnTable.map((card) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Image.asset(
                        imagePathConverter(card.id),
                        width: 60,
                        height: 90,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Wynik i reset
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'win+draw:',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      vm.result,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 32),
                  onPressed: vm.reset,
                  tooltip: 'RESET',
                ),
                // Liczba graczy
                Column(
                  children: [
                    const Text('players in game:', style: TextStyle(fontSize: 15)),
                    DropdownButton<int>(
                      value: vm.playersNum,
                      items: List.generate(9, (i) => i + 2)
                          .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          vm.playersNum = val;
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),
            // Talia kart do wyboru
            Expanded(
              child: IgnorePointer(
                ignoring: !vm.addCards,
                child: GridView.count(
                  crossAxisCount: 13,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: vm.deck.map((card) {
                    if (!card.visibility) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () => vm.onCardSelected(card.id),
                      child: Image.asset(
                        imagePathConverter(card.id),
                        width: 40,
                        height: 60,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}