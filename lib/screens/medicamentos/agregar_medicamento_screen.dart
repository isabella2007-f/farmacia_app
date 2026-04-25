import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/medicamento_provider.dart';
import '../../models/laboratorio_model.dart';
import '../../models/medicamento_model.dart';
import '../../repositories/laboratorio_repository.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';

class AgregarMedicamentoScreen extends StatefulWidget {
  final MedicamentoModel? medicamentoExistente; // null = crear, !null = editar

  const AgregarMedicamentoScreen({super.key, this.medicamentoExistente});

  @override
  State<AgregarMedicamentoScreen> createState() =>
      _AgregarMedicamentoScreenState();
}

class _AgregarMedicamentoScreenState
    extends State<AgregarMedicamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();

  LaboratorioModel? _laboratorioSeleccionado;
  DateTime? _fechaVencimiento;
  List<LaboratorioModel> _laboratorios = [];
  bool _cargandoLabs = true;

  final _labRepo = LaboratorioRepository();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  bool get _isEditing => widget.medicamentoExistente != null;

  @override
  void initState() {
    super.initState();
    _cargarLaboratorios();
    if (_isEditing) _llenarFormulario();
  }

  void _llenarFormulario() {
    final med = widget.medicamentoExistente!;
    _nombreCtrl.text = med.nombre;
    _cantidadCtrl.text = med.cantidad.toString();
    _fechaVencimiento = med.fechaVencimiento;
    _fechaCtrl.text = _dateFormat.format(med.fechaVencimiento);
  }

  Future<void> _cargarLaboratorios() async {
    final labs = await _labRepo.getLaboratorios();
    setState(() {
      _laboratorios = labs;
      _cargandoLabs = false;

      // Si estamos editando, preseleccionar el laboratorio
      if (_isEditing) {
        _laboratorioSeleccionado = labs.firstWhere(
          (l) => l.id == widget.medicamentoExistente!.laboratorioId,
          orElse: () => labs.first,
        );
      }
    });
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento ?? DateTime.now().add(
        const Duration(days: 365),
      ),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (fecha != null) {
      setState(() {
        _fechaVencimiento = fecha;
        _fechaCtrl.text = _dateFormat.format(fecha);
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_laboratorioSeleccionado == null) {
      _showError('Selecciona un laboratorio');
      return;
    }
    if (_fechaVencimiento == null) {
      _showError('Selecciona la fecha de vencimiento');
      return;
    }

    final provider = context.read<MedicamentoProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.actualizarMedicamento(
        medicamento: widget.medicamentoExistente!,
        nombre: _nombreCtrl.text,
        laboratorio: _laboratorioSeleccionado!,
        fechaVencimiento: _fechaVencimiento!,
        cantidad: int.parse(_cantidadCtrl.text),
      );
    } else {
      success = await provider.agregarMedicamento(
        nombre: _nombreCtrl.text,
        laboratorio: _laboratorioSeleccionado!,
        fechaVencimiento: _fechaVencimiento!,
        cantidad: int.parse(_cantidadCtrl.text),
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Medicamento actualizado ✓'
                : 'Medicamento registrado ✓',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      _showError(provider.error ?? 'Error desconocido');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cantidadCtrl.dispose();
    _fechaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Medicamento' : 'Nuevo Medicamento'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              Text('Nombre del medicamento',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _nombreCtrl,
                label: 'Nombre',
                hint: 'Ej: Ibuprofeno 400mg',
                prefixIcon: const Icon(Icons.medication_outlined, size: 20),
                validator: (v) =>
                    v?.isEmpty == true ? 'Ingresa el nombre' : null,
              ),

              const SizedBox(height: 24),

              // Laboratorio
              Text('Laboratorio',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              _cargandoLabs
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<LaboratorioModel>(
                          value: _laboratorioSeleccionado,
                          isExpanded: true,
                          hint: const Text('Selecciona laboratorio'),
                          items: _laboratorios.map((lab) {
                            return DropdownMenuItem(
                              value: lab,
                              child: Row(
                                children: [
                                  const Icon(Icons.business_outlined,
                                      size: 18,
                                      color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text(lab.nombre),
                                  const Spacer(),
                                  // Mostrar política de alerta
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${lab.diasAlerta}d',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (lab) =>
                              setState(() => _laboratorioSeleccionado = lab),
                        ),
                      ),
                    ),

              // Mostrar política de alerta del laboratorio seleccionado
              if (_laboratorioSeleccionado != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.info.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.info, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Alerta ${_laboratorioSeleccionado!.diasAlerta} días '
                          'antes del vencimiento'
                          '${_fechaVencimiento != null ? ': ${_dateFormat.format(_fechaVencimiento!.subtract(Duration(days: _laboratorioSeleccionado!.diasAlerta)))}' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Fecha de vencimiento
              Text('Fecha de vencimiento',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _fechaCtrl,
                label: 'Fecha de vencimiento',
                hint: 'dd/mm/aaaa',
                readOnly: true,
                onTap: _seleccionarFecha,
                prefixIcon: const Icon(Icons.calendar_today_outlined,
                    size: 20),
                validator: (v) =>
                    v?.isEmpty == true ? 'Selecciona la fecha' : null,
              ),

              const SizedBox(height: 24),

              // Cantidad
              Text('Cantidad disponible',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _cantidadCtrl,
                label: 'Cantidad',
                hint: 'Ej: 100',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon: const Icon(Icons.inventory_2_outlined,
                    size: 20),
                validator: (v) {
                  if (v?.isEmpty == true) return 'Ingresa la cantidad';
                  if (int.tryParse(v!) == null) return 'Número inválido';
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // Botón guardar
              Consumer<MedicamentoProvider>(
                builder: (_, prov, __) => CustomButton(
                  text: _isEditing ? 'Guardar cambios' : 'Registrar medicamento',
                  onPressed: _guardar,
                  isLoading: prov.isLoading,
                  icon: _isEditing
                      ? Icons.save_outlined
                      : Icons.add_circle_outline,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}