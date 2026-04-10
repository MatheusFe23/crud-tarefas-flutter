import 'package:flutter/material.dart';

/// Modelo que representa um item da lista de tarefas.
class Item {
  /// Identificador único gerado automaticamente.
  final String id;

  /// Título ou nome do item.
  String title;

  /// Descrição detalhada do item.
  String description;

  /// Data de início da tarefa (opcional).
  DateTime? startDate;

  /// Data de término da tarefa (opcional).
  DateTime? endDate;

  Item({
    required this.id,
    required this.title,
    required this.description,
    this.startDate,
    this.endDate,
  });

  /// Cor única associada ao item, derivada do [id] — consistente entre rebuilds.
  Color get color {
    const colors = [
      Color(0xFF4A90D9), // azul
      Color(0xFF5CB85C), // verde
      Color(0xFFE8873A), // laranja
      Color(0xFF9B59B6), // roxo
      Color(0xFF1ABC9C), // teal
      Color(0xFFE91E8C), // rosa
      Color(0xFF3F51B5), // índigo
      Color(0xFFFF9800), // âmbar
    ];
    return colors[id.hashCode.abs() % colors.length];
  }

  /// Indica se o item possui intervalo de datas completo.
  bool get hasDates => startDate != null && endDate != null;

  /// Cria uma cópia do item com campos opcionalmente alterados.
  Item copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
  }) {
    return Item(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }
}
