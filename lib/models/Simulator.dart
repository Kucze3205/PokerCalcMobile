// ignore: file_names
import 'dart:math';
import 'cardModel.dart';
import 'dart:isolate';

typedef SendValueCallback = void Function(double result);

void runSimulation(Map args) {
  final CardModel first = args['first'];
  final CardModel second = args['second'];
  final List<CardModel> inGameCards = args['inGameCards'];
  final int playersNum = args['playersNum'];
  final SendPort mainPort = args['mainPort'];
  final Map<String, int> hierarchy = args['hierarchy'] as Map<String, int>;
  final int updateEvery = args['updateEvery'] ?? 2000;

  final simulator = Simulator();
  simulator.fullHierarchy = hierarchy;

  simulator.probability(
    first,
    second,
    inGameCards,
    playersNum,
    updateEvery,
    mainPort,
  );
}

class Simulator {
  SendValueCallback? sendValue;
  List<int> combination = [];
  
  Map<String, int> fullHierarchy = {};

  // Symulacja rozdań
  void probability(
    CardModel first,
    CardModel second,
    List<CardModel> table,
    int players,
    int updateEvery,
    SendPort? mainPort
  ){
    const String type = "hdcs";
    final Random rnd = Random();
    int games = 0, wins = 0;

    for (int counter = 1; ; counter++) {
      final Set<String> handCards = {first.id, second.id};
      bool win = true;
      List<CardModel> actTable = List<CardModel>.from(table);

      // Dobierz brakujące karty na stole
      while (actTable.length < 5) {
        CardModel card;
        do {
          String cardId = type[rnd.nextInt(4)] + (rnd.nextInt(13) + 2).toString();
          card = CardModel(cardId);
        } while (
          actTable.any((c) => c.id == card.id) ||
          handCards.contains(card.id)
        );
        actTable.add(card);
      }

      int myValue = findBestValue(first, second, actTable);

      // Symulacja przeciwników
      for (int i = 0; i < players - 1; i++) {
        List<CardModel> oppHand = [];
        for (int j = 0; j < 2; j++) {
          CardModel oppCard;
          do {
            String cardId = type[rnd.nextInt(4)] + (rnd.nextInt(13) + 2).toString();
            oppCard = CardModel(cardId);
          } while (
            actTable.any((c) => c.id == oppCard.id) ||
            handCards.contains(oppCard.id) ||
            oppHand.any((c) => c.id == oppCard.id)
          );
          oppHand.add(oppCard);
          handCards.add(oppCard.id);
        }
        int oppVal = findBestValue(oppHand[0], oppHand[1], actTable);
        if (oppVal < myValue) {
          win = false;
          break;
        }
      }

      games++;
      if (win) wins++;

      if (counter % updateEvery == 0) {
        final probability = wins / games;
        mainPort?.send(probability);
      }
    }
  }

  // Szukanie najlepszego układu z 7 kart
  int findBestValue(CardModel first, CardModel second, List<CardModel> formation) {
    List<CardModel?> sortedF = List<CardModel?>.from(formation);
    sortedF.add(first);
    sortedF.add(second);

    sortedF.sort((a, b) {
      if (a == null || b == null) return 0;
      int cmp = a.type.compareTo(b.type);
      return cmp != 0 ? cmp : a.value.compareTo(b.value);
    });

    int bestVal = 1 << 30; // duża liczba

    for (int i = 0; i < 6; i++) {
      var save1 = sortedF[i];
      sortedF[i] = null;
      for (int j = i + 1; j < 7; j++) {
        var save2 = sortedF[j];
        sortedF[j] = null;

        String formationString = sortedF.where((x) => x != null).map((x) => x!.id).join();
        int? actVal = fullHierarchy[formationString];
        if (actVal != null && actVal < bestVal) {
          bestVal = actVal;
        }

        sortedF[j] = save2;
      }
      sortedF[i] = save1;
    }
    return bestVal;
  }
}