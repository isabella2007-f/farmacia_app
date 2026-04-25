import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;
  bool _isRegisterMode = false;
  final _nombreCtrl = TextEditingController();
  final _farmaciaCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nombreCtrl.dispose();
    _farmaciaCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    bool success;
    if (_isRegisterMode) {
      success = await authProvider.register(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        nombre: _nombreCtrl.text,
        farmacia: _farmaciaCtrl.text,
      );
    } else {
      success = await authProvider.login(
        _emailCtrl.text,
        _passwordCtrl.text,
      );
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Error desconocido'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ─── RECUPERAR CONTRASEÑA ─────────────────────────────────
  void _showRecoverPasswordDialog() {
    final emailCtrl = TextEditingController(text: _emailCtrl.text);
    final formKey = GlobalKey<FormState>();
    bool enviando = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: AppColors.surface,
            title: Column(
              children: [
                // Ícono
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Recuperar contraseña',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'ejemplo@correo.com',
                      prefixIcon: const Icon(
                        Icons.mail_outline_rounded,
                        size: 20,
                      ),
                    ),
                    validator: (v) {
                      if (v?.isEmpty == true) {
                        return 'Ingresa tu correo';
                      }
                      if (!v!.contains('@')) {
                        return 'Correo inválido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              // Botón cancelar
              TextButton(
                onPressed: enviando
                    ? null
                    : () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              // Botón enviar
              ElevatedButton(
                onPressed: enviando
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;

                        setStateDialog(() => enviando = true);

                        try {
                          await context
                              .read<AuthProvider>()
                              .resetPassword(emailCtrl.text);

                          if (context.mounted) {
                            Navigator.pop(context);
                            _showSuccessSnackbar(emailCtrl.text);
                          }
                        } catch (e) {
                          setStateDialog(() => enviando = false);
                          if (context.mounted) {
                            _showErrorSnackbar(
                              'No pudimos enviar el correo. Verifica el email ingresado.',
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: enviando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Enviar enlace',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSuccessSnackbar(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Correo enviado a $email. Revisa tu bandeja de entrada.',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Logo
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),

              const SizedBox(height: 28),

              // Título
              Text(
                _isRegisterMode ? 'Crear cuenta' : 'Bienvenido',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 6),
              Text(
                _isRegisterMode
                    ? 'Registra tu farmacia en el sistema'
                    : 'Inicia sesión para continuar',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 36),

              // Formulario
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campos solo en modo registro
                    if (_isRegisterMode) ...[
                      CustomTextField(
                        controller: _nombreCtrl,
                        label: 'Tu nombre',
                        hint: 'Ej: Carlos García',
                        prefixIcon: const Icon(
                            Icons.person_outline_rounded, size: 20),
                        validator: (v) => v?.isEmpty == true
                            ? 'Ingresa tu nombre'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _farmaciaCtrl,
                        label: 'Nombre de la farmacia',
                        hint: 'Ej: Farmacia Central',
                        prefixIcon: const Icon(
                            Icons.store_outlined, size: 20),
                        validator: (v) => v?.isEmpty == true
                            ? 'Ingresa el nombre de la farmacia'
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email
                    CustomTextField(
                      controller: _emailCtrl,
                      label: 'Correo electrónico',
                      hint: 'ejemplo@farmacia.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                          Icons.mail_outline_rounded, size: 20),
                      validator: (v) {
                        if (v?.isEmpty == true) {
                          return 'Ingresa tu correo';
                        }
                        if (!v!.contains('@')) return 'Correo inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Contraseña
                    CustomTextField(
                      controller: _passwordCtrl,
                      label: 'Contraseña',
                      obscureText: !_showPassword,
                      prefixIcon: const Icon(
                          Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                            () => _showPassword = !_showPassword),
                      ),
                      validator: (v) {
                        if (v?.isEmpty == true) {
                          return 'Ingresa tu contraseña';
                        }
                        if (v!.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),

                    // ─── OLVIDÉ MI CONTRASEÑA ──────────────
                    if (!_isRegisterMode) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showRecoverPasswordDialog,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4,
                            ),
                          ),
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Botón principal
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) => CustomButton(
                        text: _isRegisterMode
                            ? 'Crear cuenta'
                            : 'Iniciar sesión',
                        onPressed: _submit,
                        isLoading: auth.isLoading,
                        icon: _isRegisterMode
                            ? Icons.check_circle_outline
                            : Icons.login_rounded,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cambiar modo login ↔ registro
                    TextButton(
                      onPressed: () => setState(
                          () => _isRegisterMode = !_isRegisterMode),
                      child: Text(
                        _isRegisterMode
                            ? '¿Ya tienes cuenta? Inicia sesión'
                            : '¿No tienes cuenta? Regístrate',
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}