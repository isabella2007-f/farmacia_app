import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicamento_provider.dart';
import '../../models/medicamento_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/estado_badge.dart';
import '../medicamentos/agregar_medicamento_screen.dart';
import '../medicamentos/lista_medicamentos_screen.dart';
import '../laboratorios/laboratorios_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const ListaMedicamentosScreen(),
    const LaboratoriosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medication_outlined),
              activeIcon: Icon(Icons.medication),
              label: 'Medicamentos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_outlined),
              activeIcon: Icon(Icons.business),
              label: 'Laboratorios',
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AgregarMedicamentoScreen(),
                ),
              ),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

// ─── TAB INICIO (Dashboard) ────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final medProvider = context.watch<MedicamentoProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buenos días 👋',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Panel de Control',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _showLogoutDialog(context, auth),
                      icon: const Icon(Icons.logout_outlined),
                      tooltip: 'Cerrar sesión',
                    ),
                  ],
                ),
              ),
            ),

            // Tarjetas de resumen
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjetas de estadísticas
                    Row(
                      children: [
                        Expanded(
                          child: StreamBuilder<List<MedicamentoModel>>(
                            stream: medProvider.vencidosStream,
                            builder: (_, snap) => _StatCard(
                              title: 'Vencidos',
                              count: snap.data?.length ?? 0,
                              icon: Icons.warning_amber_rounded,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StreamBuilder<List<MedicamentoModel>>(
                            stream: medProvider.porVencerStream,
                            builder: (_, snap) => _StatCard(
                              title: 'Por vencer',
                              count: snap.data?.length ?? 0,
                              icon: Icons.schedule_rounded,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StreamBuilder<List<MedicamentoModel>>(
                            stream: medProvider.stockBajoStream,
                            builder: (_, snap) => _StatCard(
                              title: 'Stock bajo',
                              count: snap.data?.length ?? 0,
                              icon: Icons.inventory_2_outlined,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Sección: Vencidos
                    _SectionTitle(
                      title: 'Medicamentos Vencidos',
                      subtitle: 'Requieren retiro inmediato',
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<MedicamentoModel>>(
                      stream: medProvider.vencidosStream,
                      builder: (_, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const _LoadingCard();
                        }
                        final lista = snap.data ?? [];
                        if (lista.isEmpty) {
                          return const _EmptyCard(
                            message: '✓ No hay medicamentos vencidos',
                            isPositive: true,
                          );
                        }
                        return Column(
                          children: lista.take(3).map((med) =>
                            _MedicamentoCard(medicamento: med)
                          ).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Sección: Por vencer
                    _SectionTitle(
                      title: 'Próximos a Vencer',
                      subtitle: 'Dentro del período de alerta',
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<MedicamentoModel>>(
                      stream: medProvider.porVencerStream,
                      builder: (_, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const _LoadingCard();
                        }
                        final lista = snap.data ?? [];
                        if (lista.isEmpty) {
                          return const _EmptyCard(
                            message: '✓ No hay alertas pendientes',
                            isPositive: true,
                          );
                        }
                        return Column(
                          children: lista.take(5).map((med) =>
                            _MedicamentoCard(medicamento: med)
                          ).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

// ─── WIDGETS DEL DASHBOARD ────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: count > 0 ? color : AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _MedicamentoCard extends StatelessWidget {
  final MedicamentoModel medicamento;

  const _MedicamentoCard({required this.medicamento});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Ícono de estado
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getEstadoColor(medicamento.estado).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.medication,
              color: _getEstadoColor(medicamento.estado),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicamento.nombre,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${medicamento.laboratorioNombre} · '
                  'Vence: ${dateFormat.format(medicamento.fechaVencimiento)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Badge
          EstadoBadge(estado: medicamento.estado, small: true),
        ],
      ),
    );
  }

  Color _getEstadoColor(EstadoMedicamento estado) {
    switch (estado) {
      case EstadoMedicamento.vigente:
        return AppColors.success;
      case EstadoMedicamento.porVencer:
        return AppColors.warning;
      case EstadoMedicamento.vencido:
        return AppColors.error;
    }
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  final bool isPositive;

  const _EmptyCard({required this.message, this.isPositive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPositive
            ? AppColors.success.withOpacity(0.05)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive
              ? AppColors.success.withOpacity(0.2)
              : AppColors.border,
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: isPositive ? AppColors.success : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}