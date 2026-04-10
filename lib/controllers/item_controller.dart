import 'package:flutter/foundation.dart';
import '../models/item.dart';

/// Controller que gerencia a lista de itens em memória.
///
/// Estende [ChangeNotifier] para notificar os widgets ouvintes
/// sempre que a lista for modificada (Provider pattern).
class ItemController extends ChangeNotifier {
  final List<Item> _items = [
    Item(
      id: '1',
      title: 'Estudar Flutter',
      description: 'Praticar widgets e navegação',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 3)),
    ),
    Item(
      id: '2',
      title: 'Fazer exercícios',
      description: 'Correr 30 minutos no parque',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 5)),
    ),
    Item(
      id: '3',
      title: 'Ler um livro',
      description: 'Clean Architecture - Robert Martin',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 7)),
    ),
  ];

  /// Retorna uma cópia imutável da lista de itens.
  List<Item> get items => List.unmodifiable(_items);

  /// Retorna todos os itens cujo intervalo [startDate, endDate] cobre o [day] informado.
  List<Item> getItemsForDay(DateTime day) {
    final d = _normalize(day);
    return _items.where((item) {
      if (!item.hasDates) return false;
      final start = _normalize(item.startDate!);
      final end = _normalize(item.endDate!);
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();
  }

  /// Adiciona um novo item à lista.
  void addItem(
    String title,
    String description, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final newItem = Item(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      startDate: startDate,
      endDate: endDate,
    );
    _items.add(newItem);
    notifyListeners();
  }

  /// Atualiza um item existente pelo [id].
  void updateItem(
    String id,
    String title,
    String description, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        title: title.trim(),
        description: description.trim(),
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    }
  }

  /// Remove o item com o [id] informado.
  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  /// Remove a parte de tempo de um DateTime, mantendo apenas a data.
  DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
