import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/item_controller.dart';
import '../models/item.dart';
import '../widgets/custom_text_field.dart';

/// Tela reutilizada para criação e edição de itens.
///
/// Se [item] for `null`, opera no modo criação.
/// Se [item] for fornecido, preenche os campos e opera no modo edição.
class ItemFormScreen extends StatefulWidget {
  final Item? item;

  const ItemFormScreen({super.key, this.item});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  DateTime? _startDate;
  DateTime? _endDate;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.item?.description ?? '');
    _startDate = widget.item?.startDate;
    _endDate = widget.item?.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Abre o seletor de data nativo e atualiza [_startDate] ou [_endDate].
  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: isStart ? 'Selecione a data de início' : 'Selecione a data de fim',
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        // Garante que a data fim não seja anterior ao início
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  /// Formata um DateTime para exibição no botão de seleção.
  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  /// Valida e salva o item (cria ou atualiza).
  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Validação cruzada das datas
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe as datas de início e fim.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final controller = context.read<ItemController>();

    if (_isEditing) {
      controller.updateItem(
        widget.item!.id,
        _titleController.text,
        _descriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
      );
    } else {
      controller.addItem(
        _titleController.text,
        _descriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
      );
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Item atualizado!' : 'Item criado!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              CustomTextField(
                controller: _titleController,
                label: 'Título',
                hint: 'Ex: Estudar Flutter',
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O título não pode ser vazio';
                  }
                  if (value.trim().length < 3) {
                    return 'O título deve ter ao menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descrição
              CustomTextField(
                controller: _descriptionController,
                label: 'Descrição',
                hint: 'Ex: Revisar widgets e navegação',
                maxLines: 3,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'A descrição não pode ser vazia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Rótulo da seção de datas
              Row(
                children: [
                  Icon(Icons.date_range, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Período da tarefa',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Seletores de data lado a lado
              Row(
                children: [
                  Expanded(
                    child: _DatePickerButton(
                      label: 'Início',
                      date: _startDate,
                      icon: Icons.play_circle_outline,
                      color: colorScheme.primary,
                      onTap: () => _pickDate(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerButton(
                      label: 'Fim',
                      date: _endDate,
                      icon: Icons.stop_circle_outlined,
                      color: colorScheme.tertiary,
                      onTap: () => _pickDate(isStart: false),
                      // Impede selecionar fim antes do início
                      enabled: _startDate != null,
                    ),
                  ),
                ],
              ),

              // Preview do intervalo selecionado
              if (_startDate != null && _endDate != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${_endDate!.difference(_startDate!).inDays + 1} dias de duração  '
                        '(${_formatDate(_startDate!)} → ${_formatDate(_endDate!)})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Botão salvar
              FilledButton.icon(
                onPressed: _save,
                icon: Icon(_isEditing ? Icons.save_outlined : Icons.add),
                label: Text(
                  _isEditing ? 'Salvar alterações' : 'Criar tarefa',
                  style: const TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão reutilizável que exibe a data selecionada ou convida a selecionar.
class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const _DatePickerButton({
    required this.label,
    required this.date,
    required this.icon,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  String _format(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = date != null;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled
                ? (isSelected ? color : colorScheme.outline)
                : colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? color.withValues(alpha: 0.08)
              : (enabled ? null : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: 14,
                    color: enabled ? color : colorScheme.outlineVariant),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: enabled ? color : colorScheme.outlineVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isSelected
                  ? _format(date!)
                  : (enabled ? 'Selecionar' : 'Defina o início'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? colorScheme.onSurface
                        : colorScheme.outline,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
