// ignore: file_names
import 'dart:isolate';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/cardModel.dart';
import '../models/simulator.dart';

class MainViewModel extends ChangeNotifier {
  // Pola
  static const List<String> suits = ['h', 'd', 'c', 's'];
  static const List<String> ranks = [
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    'J',
    'Q',
    'K',
    'A',
  ];

  final List<CardModel> deck = [];
  final List<CardModel> myCards = [];
  final List<CardModel> cardsOnTable = [];
  final List<CardModel> _inGameCards = [];
  final List<CardModel> _hand = [];

  Isolate? isolate;
  final responsePort = ReceivePort();
  String result = '';
  bool addCards = true;
  String? selectedSuit;
  int playersNum = 2;
  Map<String, int> hierarchy = {};

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
      String jsonContent = await rootBundle.loadString(
        "assets/cards_hierarhy/full_hierarhy5.json",
      );
      final Map<String, dynamic> jsonMap = jsonDecode(jsonContent);
      hierarchy = jsonMap.cast<String, int>();
    } catch (e) {
      debugPrint('Error loading hierarchy: $e');
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

  void selectSuit(String suit) {
    if (!addCards) return;
    if (!suits.contains(suit)) return;
    selectedSuit = suit;
    notifyListeners();
  }

  void clearSuitSelection() {
    if (selectedSuit == null) return;
    selectedSuit = null;
    notifyListeners();
  }

  bool isCardAvailable(String suit, String rank) {
    final cardId = '$suit$rank';
    for (final card in deck) {
      if (card.id == cardId) {
        return card.visibility;
      }
    }
    return false;
  }

  Future<void> onCardSelected(String str) async {
    isolate?.kill(priority: Isolate.immediate);
    isolate = null;

    CardModel? pickedDeckCard;
    for (final deckCard in deck) {
      if (deckCard.id == str) {
        pickedDeckCard = deckCard;
        break;
      }
    }

    if (pickedDeckCard == null || !pickedDeckCard.visibility) {
      return;
    }

    CardModel card = CardModel(str);

    // Hide selected card from deck
    pickedDeckCard.visibility = false;

    // Dodawanie kart
    if (_hand.length == 2) {
      _inGameCards.add(card);
      cardsOnTable.add(card);
    } else {
      _hand.add(card);
      myCards.add(card);
    }

    if (cardsOnTable.length == 5) addCards = false;
    selectedSuit = null;
    notifyListeners();

    // Symulacja
    if (_hand.length == 2) {
      isolate = await Isolate.spawn(runSimulation, {
        'first': _hand[0],
        'second': _hand[1],
        'inGameCards': List<CardModel>.from(_inGameCards),
        'playersNum': playersNum,
        'mainPort': responsePort.sendPort,
        'hierarchy': hierarchy,
        'updateEvery': 5000,
      });
    }
  }

  Future<void> removeCard(String cardId) async {
    isolate?.kill(priority: Isolate.immediate);
    isolate = null;

    result = '';

    for (final deckCard in deck) {
      if (deckCard.id == cardId) {
        deckCard.visibility = true;
        break;
      }
    }

    _hand.removeWhere((c) => c.id == cardId);
    myCards.removeWhere((c) => c.id == cardId);
    _inGameCards.removeWhere((c) => c.id == cardId);
    cardsOnTable.removeWhere((c) => c.id == cardId);

    addCards = true;
    selectedSuit = null;
    notifyListeners();

    if (_hand.length == 2) {
      isolate = await Isolate.spawn(runSimulation, {
        'first': _hand[0],
        'second': _hand[1],
        'inGameCards': List<CardModel>.from(_inGameCards),
        'playersNum': playersNum,
        'mainPort': responsePort.sendPort,
        'hierarchy': hierarchy,
        'updateEvery': 5000,
      });
    }
  }

  // Resetowanie stanu
  void reset() {
    isolate?.kill(priority: Isolate.immediate);
    isolate = null;
    _inGameCards.clear();
    _hand.clear();
    cardsOnTable.clear();
    myCards.clear();
    result = '';
    addCards = true;
    selectedSuit = null;
    for (var card in deck) {
      card.visibility = true;
    }
    notifyListeners();
  }

  // Odbiór wyniku z symulatora
  void _receiveValue(double value) {
    //await Future.delayed(const Duration(milliseconds: 4000));
    result = '${(value * 100).toStringAsFixed(2)}%';
    notifyListeners();
  }
}
