// ignore: file_names
import 'dart:isolate';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/cardModel.dart';
import '../models/simulator.dart';


class MainViewModel extends ChangeNotifier {
  // Pola
  final List<CardModel> deck = [];
  final List<CardModel> myCards = [];
  final List<CardModel> cardsOnTable = [];
  final List<CardModel> _inGameCards = [];
  final List<CardModel> _hand = [];

  Isolate? isolate;
  final responsePort = ReceivePort();
  String result = '';
  bool addCards = true;
  int playersNum = 2;
  late Map<String, int> hierarchy = {};

  MainViewModel() {
    _initDeck();
    _loadHierarchy();
    responsePort.listen((message) {
      if (message is double) {
        _receiveValue(message);
      }
    });
  }

  Future<void> _loadHierarchy() async {
    try {
      String jsonContent = await rootBundle.loadString("assets/cards_hierarhy/full_hierarhy5.json");
      final Map<String, dynamic> jsonMap = jsonDecode(jsonContent);
      hierarchy = jsonMap.cast<String, int>();
    } catch (e) {
      print('Error loading hierarchy: $e');
    }
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
      Isolate.spawn(
        runSimulation,
        {
          'first': _hand[0],
          'second': _hand[1],
          'inGameCards': List<CardModel>.from(_inGameCards),
          'playersNum': playersNum,
          'mainPort': responsePort.sendPort,
          'hierarchy': hierarchy,
        },
      );
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
    for (var card in deck) {
      card.visibility = true;
    }
    notifyListeners();
  }

  // Odbiór wyniku z symulatora
  void _receiveValue(double value) async {
    await Future.delayed(const Duration(milliseconds: 100));
    result = '${(value * 100).toStringAsFixed(2)}%';
    notifyListeners();
  }
}
