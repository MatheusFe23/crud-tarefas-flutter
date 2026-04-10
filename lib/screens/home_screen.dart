import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/item_controller.dart';
import '../models/item.dart';
import '../widgets/item_card.dart';
import 'item_form_screen.dart';
import 'login_screen.dart';

/// Tela principal — calendário com marcadores coloridos + lista de tarefas.
///
/// O calendário exibe pontos coloridos nos dias que possuem tarefas.
/// Ao tocar em um dia, a lista é filtrada para mostrar apenas as tarefas
/// cujo intervalo [startDate, endDate] cobre aquele dia.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Formata data para exibição no cabeçalho da lista.
  String _formatDay(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  // ── Ações ─────────────────────────────────────────────────────────────────

  void _openForm({Item? item}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ItemFormScreen(item: item)),
    );
  }

  Future<void> _confirmDelete(Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
            'Deseja excluir "${item.title}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<ItemController>().deleteItem(item.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item excluído.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemController>(
      builder: (context, controller, _) {
        final allItems = controller.items.toList();

        // Filtra pelo dia selecionado, ou mostra tudo
        final visibleItems = _selectedDay != null
            ? controller.getItemsForDay(_selectedDay!)
            : allItems;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Minhas Tarefas'),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                tooltip: 'Sair',
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Calendário ────────────────────────────────────────────────
              _buildCalendar(allItems),

              const Divider(height: 1),

              // ── Cabeçalho da lista ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
                child: Row(
                  children: [
                    Text(
                      _selectedDay != null
                          ? 'Tarefas em ${_formatDay(_selectedDay!)}'
                          : 'Todas as tarefas (${allItems.length})',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (_selectedDay != null) ...[
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _selectedDay = null),
                        icon: const Icon(Icons.clear, size: 14),
                        label: const Text('Limpar filtro'),
                        style: TextButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8)),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Lista de tarefas ──────────────────────────────────────────
              Expanded(
                child: visibleItems.isEmpty
                    ? _EmptyState(hasFilter: _selectedDay != null)
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: visibleItems.length,
                        itemBuilder: (_, index) {
                          final item = visibleItems[index];
                          return ItemCard(
                            item: item,
                            onEdit: () => _openForm(item: item),
                            onDelete: () => _confirmDelete(item),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openForm,
            icon: const Icon(Icons.add),
            label: const Text('Nova tarefa'),
          ),
        );
      },
    );
  }

  /// Constrói o widget TableCalendar com marcadores coloridos por tarefa.
  Widget _buildCalendar(List<Item> allItems) {
    final colorScheme = Theme.of(context).colorScheme;

    return TableCalendar<Item>(
      firstDay: DateTime(2020),
      lastDay: DateTime(2035),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

      // Retorna os itens que cobrem cada dia — usado para renderizar marcadores
      eventLoader: (day) =>
          context.read<ItemController>().getItemsForDay(day),

      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          // Toque no mesmo dia remove o filtro
          _selectedDay =
              isSameDay(_selectedDay, selectedDay) ? null : selectedDay;
          _focusedDay = focusedDay;
        });
      },

      onFormatChanged: (format) =>
          setState(() => _calendarFormat = format),

      onPageChanged: (focusedDay) =>
          setState(() => _focusedDay = focusedDay),

      // ── Aparência ───────────────────────────────────────────────────────
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        todayTextStyle:
            TextStyle(color: colorScheme.onPrimaryContainer),
        selectedDecoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle:
            TextStyle(color: colorScheme.onPrimary),
        markerSize: 0, // Desabilita marcador padrão — usamos o custom abaixo
      ),
      headerStyle: const HeaderStyle(
        formatButtonShowsNext: false,
        titleCentered: true,
        formatButtonDecoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // ── Marcadores coloridos customizados ────────────────────────────────
      calendarBuilders: CalendarBuilders<Item>(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;

          // Exibe até 4 pontos coloridos (um por tarefa) abaixo do número
          return Positioned(
            bottom: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: events.take(4).map((item) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

/// Estado vazio — muda a mensagem dependendo se há filtro ativo.
class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilter ? Icons.event_busy_outlined : Icons.inbox_outlined,
            size: 60,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            hasFilter
                ? 'Nenhuma tarefa neste dia.'
                : 'Nenhuma tarefa ainda.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          if (!hasFilter) ...[
            const SizedBox(height: 6),
            Text(
              'Toque em + para adicionar.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.outline),
            ),
          ],
        ],
      ),
    );
  }
}
