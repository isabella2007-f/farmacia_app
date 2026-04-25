import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/ajustes_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final _farmaciaCtrl = TextEditingController();
  final _umbralCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final ajustes = context.read<AjustesProvider>();
    _farmaciaCtrl.text = ajustes.nombreFarmacia;
    _umbralCtrl.text = ajustes.umbralStock.toString();
  }

  @override
  void dispose() {
    _farmaciaCtrl.dispose();
    _umbralCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ajustes = context.watch<AjustesProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ajustes'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ─── SECCIÓN: FARMACIA ─────────────────────────
            _SectionHeader(
              icon: Icons.store_outlined,
              title: 'Información de la Farmacia',
            ),
            const SizedBox(height: 12),

            _SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nombre de la farmacia',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _farmaciaCtrl,
                          style: GoogleFonts.poppins(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Ej: Farmacia Central',
                            prefixIcon: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          onChanged: (v) =>
                              ajustes.setNombreFarmacia(v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Email del usuario
                  Row(
                    children: [
                      const Icon(
                        Icons.mail_outline_rounded,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        auth.user?.email ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── SECCIÓN: STOCK ────────────────────────────
            _SectionHeader(
              icon: Icons.inventory_2_outlined,
              title: 'Control de Stock',
            ),
            const SizedBox(height: 12),

            _SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Umbral de stock bajo',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Alertar cuando haya menos de esta cantidad',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Slider + Input
                  Row(
                    children: [
                      // Slider
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: AppColors.primaryLighter,
                            thumbColor: AppColors.primary,
                            overlayColor:
                                AppColors.primary.withOpacity(0.1),
                            valueIndicatorColor: AppColors.primary,
                            valueIndicatorTextStyle:
                                GoogleFonts.poppins(color: Colors.white),
                          ),
                          child: Slider(
                            value: ajustes.umbralStock.toDouble(),
                            min: 1,
                            max: 100,
                            divisions: 99,
                            label: '${ajustes.umbralStock} uds',
                            onChanged: (v) {
                              ajustes.setUmbralStock(v.round());
                              _umbralCtrl.text = v.round().toString();
                            },
                          ),
                        ),
                      ),

                      // Input numérico
                      Container(
                        width: 72,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLighter,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextFormField(
                          controller: _umbralCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (v) {
                            final valor = int.tryParse(v);
                            if (valor != null &&
                                valor >= 1 &&
                                valor <= 100) {
                              ajustes.setUmbralStock(valor);
                            }
                          },
                        ),
                      ),

                      const SizedBox(width: 8),
                      Text(
                        'uds',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Info visual del umbral
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Se mostrarán alertas para medicamentos '
                            'con menos de ${ajustes.umbralStock} unidades',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── SECCIÓN: NOTIFICACIONES ───────────────────
            _SectionHeader(
              icon: Icons.notifications_outlined,
              title: 'Notificaciones',
            ),
            const SizedBox(height: 12),

            _SettingsCard(
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: ajustes.notificacionesActivas
                          ? AppColors.primaryLighter
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      ajustes.notificacionesActivas
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_outlined,
                      color: ajustes.notificacionesActivas
                          ? AppColors.primary
                          : AppColors.textHint,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notificaciones push',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          ajustes.notificacionesActivas
                              ? 'Recibirás alertas de vencimientos'
                              : 'Las alertas están desactivadas',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: ajustes.notificacionesActivas,
                    onChanged: (v) => ajustes.setNotificaciones(v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── SECCIÓN: CUENTA ───────────────────────────
            _SectionHeader(
              icon: Icons.person_outline_rounded,
              title: 'Cuenta',
            ),
            const SizedBox(height: 12),

            _SettingsCard(
              child: Column(
                children: [
                  // Versión
                  _InfoRow(
                    icon: Icons.info_outline_rounded,
                    label: 'Versión',
                    value: '1.0.0',
                  ),
                  const Divider(height: 20),

                  // Cerrar sesión
                  InkWell(
                    onTap: () => _confirmarCerrarSesion(context, auth),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Cerrar sesión',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.error,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Footer con amor 💙
            Center(
              child: Text(
                'Hecha con 💙 para ti',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmarCerrarSesion(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cerrar sesión',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              auth.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

// ─── WIDGETS REUTILIZABLES ────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}