import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../repositories/laboratorio_repository.dart';
import '../../models/laboratorio_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';

class LaboratoriosScreen extends StatelessWidget {
  const LaboratoriosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = LaboratorioRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laboratorios'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showFormDialog(context, repo),
            tooltip: 'Nuevo laboratorio',
          ),
        ],
      ),
      body: StreamBuilder<List<LaboratorioModel>>(
        stream: repo.getLaboratoriosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final labs = snapshot.data ?? [];

          if (labs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business_outlined,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  const Text('No hay laboratorios registrados'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showFormDialog(context, repo),
                    child: const Text('Agregar laboratorio'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: labs.length,
            itemBuilder: (context, i) {
              final lab = labs[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.business,
                        color: AppColors.primary),
                  ),
                  title: Text(lab.nombre,
                      style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      // Chip mostrando política de alerta
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Alerta: ${lab.diasAlerta} días antes',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                      if (lab.contactoEmail.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(lab.contactoEmail,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 18),
                        onPressed: () =>
                            _showFormDialog(context, repo, lab),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: AppColors.error),
                        onPressed: () =>
                            _confirmarEliminar(context, repo, lab),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showFormDialog(BuildContext context, LaboratorioRepository repo,
      [LaboratorioModel? lab]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LaboratorioForm(repo: repo, laboratorio: lab),
    );
  }

  void _confirmarEliminar(BuildContext context,
      LaboratorioRepository repo, LaboratorioModel lab) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar laboratorio'),
        content: Text('¿Eliminar "${lab.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              repo.eliminarLaboratorio(lab.id);
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

class _LaboratorioForm extends StatefulWidget {
  final LaboratorioRepository repo;
  final LaboratorioModel? laboratorio;

  const _LaboratorioForm({required this.repo, this.laboratorio});

  @override
  State<_LaboratorioForm> createState() => _LaboratorioFormState();
}

class _LaboratorioFormState extends State<_LaboratorioForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _diasCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  bool get _isEditing => widget.laboratorio != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nombreCtrl.text = widget.laboratorio!.nombre;
      _diasCtrl.text = widget.laboratorio!.diasAlerta.toString();
      _emailCtrl.text = widget.laboratorio!.contactoEmail;
    } else {
      _diasCtrl.text = '30';
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final lab = LaboratorioModel(
        id: widget.laboratorio?.id ?? '',
        nombre: _nombreCtrl.text.trim(),
        diasAlerta: int.parse(_diasCtrl.text),
        contactoEmail: _emailCtrl.text.trim(),
        creadoEn: widget.laboratorio?.creadoEn ?? DateTime.now(),
      );

      if (_isEditing) {
        await widget.repo.actualizarLaboratorio(lab);
      } else {
        await widget.repo.crearLaboratorio(lab);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              _isEditing ? 'Editar laboratorio' : 'Nuevo laboratorio',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            CustomTextField(
              controller: _nombreCtrl,
              label: 'Nombre del laboratorio',
              prefixIcon: const Icon(Icons.business_outlined, size: 20),
              validator: (v) =>
                  v?.isEmpty == true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _diasCtrl,
              label: 'Días de alerta antes del vencimiento',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefixIcon: const Icon(Icons.schedule, size: 20),
              validator: (v) {
                if (v?.isEmpty == true) return 'Campo requerido';
                final dias = int.tryParse(v!);
                if (dias == null || dias < 1) return 'Ingresa un número válido';
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Ejemplo: 30 = se alertará 30 días antes de que el medicamento venza',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
            ),

            const SizedBox(height: 16),

            CustomTextField(
              controller: _emailCtrl,
              label: 'Email de contacto (opcional)',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.mail_outline, size: 20),
            ),

            const SizedBox(height: 32),

            CustomButton(
              text: _isEditing ? 'Guardar cambios' : 'Crear laboratorio',
              onPressed: _guardar,
              isLoading: _isLoading,
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _diasCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }
}