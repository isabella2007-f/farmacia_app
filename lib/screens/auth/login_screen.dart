import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
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
              const SizedBox(height: 60),

              // Logo / Ícono
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              const SizedBox(height: 32),

              // Título
              Text(
                _isRegisterMode ? 'Crear cuenta' : 'Bienvenido',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _isRegisterMode
                    ? 'Registra tu farmacia en el sistema'
                    : 'Inicia sesión para continuar',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 40),

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
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Ingresa tu nombre' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _farmaciaCtrl,
                        label: 'Nombre de la farmacia',
                        hint: 'Ej: Farmacia Central',
                        prefixIcon: const Icon(Icons.store_outlined, size: 20),
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
                      prefixIcon: const Icon(Icons.mail_outline, size: 20),
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Ingresa tu correo';
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
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Ingresa tu contraseña';
                        if (v!.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Botón principal
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) => CustomButton(
                        text: _isRegisterMode ? 'Crear cuenta' : 'Iniciar sesión',
                        onPressed: _submit,
                        isLoading: auth.isLoading,
                        icon: _isRegisterMode
                            ? Icons.check_circle_outline
                            : Icons.login,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cambiar modo (login ↔ registro)
                    TextButton(
                      onPressed: () => setState(
                          () => _isRegisterMode = !_isRegisterMode),
                      child: Text(
                        _isRegisterMode
                            ? '¿Ya tienes cuenta? Inicia sesión'
                            : '¿No tienes cuenta? Regístrate',
                        style: const TextStyle(color: AppColors.primary),
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