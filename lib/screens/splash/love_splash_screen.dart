import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';
import '../../core/constants/app_colors.dart';

// Lista de mensajes de amor - cambia aleatoriamente cada vez
const List<String> _mensajesAmor = [
  "Eres la razón por la que\nsonrío cada día 💙",
  "Esta app fue hecha con\ntodo mi amor para ti 💫",
  "Cuidas a todos en tu farmacia\ny yo te cuido a ti ❤️",
  "Eres increíble en todo\nlo que haces, mi amor 🌟",
  "Gracias por ser tan\ndedicado y especial 💙",
  "Esta app es tan especial\ncomo tú lo eres para mí ✨",
  "Te amo más que ayer\ny menos que mañana 💫",
  "Eres mi persona favorita\nen todo el universo 🌙",
  "Hoy y siempre,\nestoy orgullosa de ti 💙",
  "Mi amor por ti es\ntan grande como el mar 🌊",
];

class LoveSplashScreen extends StatefulWidget {
  const LoveSplashScreen({super.key});

  @override
  State<LoveSplashScreen> createState() => _LoveSplashScreenState();
}

class _LoveSplashScreenState extends State<LoveSplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _heartController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _heartAnimation;

  late String _mensajeSeleccionado;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Seleccionar mensaje aleatorio
    final random = Random();
    _mensajeSeleccionado =
        _mensajesAmor[random.nextInt(_mensajesAmor.length)];

    // Generar partículas de corazones flotantes
    for (int i = 0; i < 12; i++) {
      _particles.add(_Particle(random));
    }

    // Controlador de fade principal
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
    );

    // Controlador del corazón pulsante
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );

    // Controlador de partículas
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Iniciar animación
    _fadeController.forward();

    // Navegar después de 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _navigateToLogin();
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _heartController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.loveGradient,
        ),
        child: Stack(
          children: [
            // Partículas flotantes de fondo
            ...List.generate(_particles.length, (i) {
              return AnimatedBuilder(
                animation: _particleController,
                builder: (_, __) {
                  final progress =
                      (_particleController.value + _particles[i].offset) % 1.0;
                  final y = size.height -
                      (progress * (size.height + 100)) - 50;
                  final x = _particles[i].x * size.width;
                  final opacity = progress < 0.2
                      ? progress / 0.2
                      : progress > 0.8
                          ? (1 - progress) / 0.2
                          : 1.0;

                  return Positioned(
                    left: x,
                    top: y,
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Text(
                        _particles[i].emoji,
                        style: TextStyle(
                          fontSize: _particles[i].size,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Círculo decorativo superior
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Círculo decorativo inferior
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Contenido principal
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ícono de la app con corazón
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Halo brillante
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            // Ícono principal
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.medication_rounded,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                            // Corazón pulsante
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: AnimatedBuilder(
                                animation: _heartAnimation,
                                builder: (_, __) => Transform.scale(
                                  scale: _heartAnimation.value,
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFFF4081),
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Nombre de la app
                        Text(
                          'Farmacia App',
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Subtítulo
                        Text(
                          'Hecha con amor, para ti 💙',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.75),
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Tarjeta del mensaje de amor
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 28,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Corazones decorativos
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('💙', style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Text('✨', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Text('💙', style: TextStyle(fontSize: 20)),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Mensaje de amor
                              Text(
                                _mensajeSeleccionado,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Firma
                              Text(
                                '— Con todo mi amor 🌙',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Indicador de carga elegante
                        Column(
                          children: [
                            SizedBox(
                              width: 120,
                              child: LinearProgressIndicator(
                                backgroundColor:
                                    Colors.white.withOpacity(0.2),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Preparando tu app...',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Botón para saltar
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: _navigateToLogin,
                child: Text(
                  'Saltar →',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Clase para las partículas flotantes
class _Particle {
  final double x;
  final double offset;
  final double size;
  final String emoji;

  _Particle(Random random)
      : x = random.nextDouble(),
        offset = random.nextDouble(),
        size = 12 + random.nextDouble() * 16,
        emoji = ['💙', '✨', '⭐', '💫', '🌟'][random.nextInt(5)];
}