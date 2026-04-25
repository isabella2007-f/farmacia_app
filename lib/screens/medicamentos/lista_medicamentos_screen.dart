import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/medicamento_provider.dart';
import '../../models/medicamento_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/estado_badge.dart';
import 'agregar_medicamento_screen.dart';

class ListaMedicamentosScreen extends StatefulWidget {
  const ListaMedicamentosScreen({super.key});

  @override
  State<ListaMedicamentosScreen> createState() =>
      _ListaMedicamentosScreenState();
}

class _ListaMedicamentosScreenState
    extends State<ListaMedicamentosScreen> {
  String _searchQuery = '';
  EstadoMedicamento? _filtroEstado;

  @override
  Widget build(BuildContext context) {
    final medProvider = context.watch<MedicamentoProvider>();
    final dateFormat = DateFormat('dd MMM yyyy', 'es');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medicamentos'),
        automaticallyImplyLeading: false,
        actions: [
          // Filtro
          PopupMenuButton<EstadoMedicamento?>(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_filtroEstado != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onSelected: (estado) =>
                setState(() => _filtroEstado = estado),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Todos')),
              const PopupMenuItem(
                  value: EstadoMedicamento.vigente,
                  child: Text('Vigentes')),
              const PopupMenuItem(
                  value: EstadoMedicamento.porVencer,
                  child: Text('Por vencer')),
              const PopupMenuItem(
                  value: EstadoMedicamento.vencido,
                  child: Text('Vencidos')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Buscar medicamento o laboratorio...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () =>
                            setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Lista
          Expanded(
            child: StreamBuilder<List<MedicamentoModel>>(
              stream: medProvider.medicamentosStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                var medicamentos = snapshot.data ?? [];

                // Aplicar búsqueda
                if (_searchQuery.isNotEmpty) {
                  medicamentos = medicamentos
                      .where((m) =>
                          m.nombre.toLowerCase().contains(_searchQuery) ||
                          m.laboratorioNombre
                              .toLowerCase()
                              .contains(_searchQuery))
                      .toList();
                }

                // Aplicar filtro de estado
                if (_filtroEstado != null) {
                  medicamentos = medicamentos
                      .where((m) => m.estado == _filtroEstado)
                      .toList();
                }

                if (medicamentos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Sin resultados para "$_searchQuery"'
                              : 'No hay medicamentos registrados',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: medicamentos.length,
                  itemBuilder: (context, index) {
                    final med = medicamentos[index];
                    return _MedicamentoListTile(
                      medicamento: med,
                      dateFormat: dateFormat,
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AgregarMedicamentoScreen(
                            medicamentoExistente: med,
                          ),
                        ),
                      ),
                      onDelete: () =>
                          _confirmarEliminar(context, med),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(
      BuildContext context, MedicamentoModel med) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar medicamento'),
        content: Text(
            '¿Eliminar "${med.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MedicamentoProvider>().eliminarMedicamento(med.id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _MedicamentoListTile extends StatelessWidget {
  final MedicamentoModel medicamento;
  final DateFormat dateFormat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MedicamentoListTile({
    required this.medicamento,
    required this.dateFormat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.medication, color: AppColors.primary),
        ),
        title: Text(
          medicamento.nombre,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              medicamento.laboratorioNombre,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Vence: ${dateFormat.format(medicamento.fechaVencimiento)} '
              '· Stock: ${medicamento.cantidad}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 12),
            ),
            // Días restantes
            Text(
              medicamento.diasParaVencer >= 0
                  ? '${medicamento.diasParaVencer} días restantes'
                  : 'Venció hace ${medicamento.diasParaVencer.abs()} días',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: medicamento.diasParaVencer >= 0
                    ? AppColors.textSecondary
                    : AppColors.error,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            EstadoBadge(estado: medicamento.estado, small: true),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert,
                  size: 20, color: AppColors.textSecondary),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Eliminar',
                          style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}