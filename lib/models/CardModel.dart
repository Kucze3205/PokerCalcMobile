// ignore: file_names
// ignore: file_names
import 'package:flutter/foundation.dart';


class CardModel extends ChangeNotifier {
  late String id;
  late int idInInt;
  late int type;
  late int value;
  bool _visibility = true;

  bool get visibility => _visibility;
  set visibility(bool val) {
    _visibility = val;
    notifyListeners();
  }

  CardModel(this.id) {
    // Typ karty na podstawie pierwszego znaku
    switch (id[0]) {
      case 'h': type = 0; break;
      case 'd': type = 1; break;
      case 'c': type = 2; break;
      case 's': type = 3; break;
      default: throw Exception('Card type error');
    }

    // Wartość karty
    String valueC = id.substring(1);
    switch (valueC) {
      case 'T': valueC = '10'; break;
      case 'J': valueC = '11'; break;
      case 'Q': valueC = '12'; break;
      case 'K': valueC = '13'; break;
      case 'A': valueC = '14'; break;
    }
    value = int.parse(valueC) - 2;
    idInInt = type * 12 + value;
  }

  // Porównanie kart
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModel &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          value == other.value;

  @override
  int get hashCode => Object.hash(type, value);

  // Wywołanie metody po kliknięciu (możesz podpiąć callback w UI)
  void onCardClicked(void Function(String) method) {
    visibility = false;
    method(id);
  }
}