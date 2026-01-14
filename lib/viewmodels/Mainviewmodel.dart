// ignore: file_names
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import '../models/cardModel.dart';
import '../models/simulator.dart';



class MainViewModel extends ChangeNotifier {
  // Pola
  final List<CardModel> deck = [];
  final List<CardModel> myCards = [];
  final List<CardModel> cardsOnTable = [];
  final List<CardModel> _inGameCards = [];
  final List<CardModel> _hand = [];
  late final Simulator simulator;
  Isolate? isolate;
  final responsePort = ReceivePort();
  String result = '';
  bool addCards = true;
  int playersNum = 2;
  bool _isSimulating = false;

  MainViewModel() {
    _initDeck();
    simulator = Simulator();
    simulator.sendValue = _receiveValue;
  }

  // Inicjalizacja talii
  void _initDeck() {
    const String type = "hdcs";
    for (var t in type.split('')) {
      for (int i = 2; i < 15; i++) {
        final card = CardModel('$t$i');
        deck.add(card);
      }
    }
    notifyListeners();
  }

  void onCardSelected(String str) {
    _isSimulating = false; // Anulowanie poprzedniej operacji

    CardModel card = CardModel(str);
    // Dodawanie kart
    if (_hand.length == 2) {
      _inGameCards.add(card);
      cardsOnTable.add(card);
    } else {
      _hand.add(card);
      myCards.add(card);
    }

    if (cardsOnTable.length == 5) addCards = false;
    notifyListeners();

    // Symulacja
    if (_hand.length == 2) {
      _isSimulating = true;
      Isolate.spawn(
        runSimulation,
        {
          'simulator': simulator,
          'first': _hand[0],
          'second': _hand[1],
          'inGameCards': List<CardModel>.from(_inGameCards),
          'playersNum': playersNum,
          'mainPort': responsePort.sendPort,
        },
      );
      responsePort.listen((message) {
        if (message is double) {
          _receiveValue(message);
        }
      });
    }
  }

  // Resetowanie stanu
  void reset() {
    _inGameCards.clear();
    _hand.clear();
    cardsOnTable.clear();
    myCards.clear();
    result = '';
    addCards = true;
    _isSimulating = false;
    for (var card in deck) {
      card.visibility = true;
    }
    notifyListeners();
  }

  // Odbiór wyniku z symulatora
  void _receiveValue(double value) async {
    result = '${(value * 100).toStringAsFixed(2)}%';
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 350));
  }
}
