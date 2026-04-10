import 'package:flutter/material.dart';
import '../models/item.dart';

/// Card reutilizável que representa um item na lista da tela principal.
///
/// Exibe título, descrição, intervalo de datas e botões de editar/excluir.
/// A faixa colorida à esquerda reflete a cor única do item no calendário.
class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Faixa colorida à esquerda — mesma cor do marcador no calendário
            Container(width: 5, color: item.color),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                child: Row(
                  children: [
                    // Conteúdo textual
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.description.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              item.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: colorScheme.onSurfaceVariant),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          // Linha de datas
                          if (item.hasDates) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 11, color: item.color),
                                const SizedBox(width: 4),
                                Text(
                                  '${_formatDate(item.startDate!)}  →  ${_formatDate(item.endDate!)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: item.color),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Botão editar
                    IconButton(
                      tooltip: 'Editar',
                      icon:
                          Icon(Icons.edit_outlined, color: colorScheme.primary),
                      onPressed: onEdit,
                    ),

                    // Botão excluir
                    IconButton(
                      tooltip: 'Excluir',
                      icon: Icon(Icons.delete_outline, color: colorScheme.error),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
