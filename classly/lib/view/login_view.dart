import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  bool _senhaOculta = true;

  static const Color _teal = Color(0xFF00B8A0);
  static const Color _tealEscuro = Color(0xFF00796B);
  static const Color _textoEscuro = Color(0xFF0F172A);
  static const Color _campoFundo = Color(0xFFF8FAFC);
  static const Color _campoBorda = Color(0xFFE2E8F0);
  static const Color _erro = Color(0xFFEF4444);

  InputDecoration _decoracaoCampo({
    required String hint,
    required IconData icone,
    Widget? sufixo,
  }) {
    OutlineInputBorder borda(Color cor) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cor),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: _campoFundo,
      prefixIcon: Icon(icone, color: const Color(0xFF94A3B8)),
      suffixIcon: sufixo,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: borda(_campoBorda),
      enabledBorder: borda(_campoBorda),
      focusedBorder: borda(_teal),
      errorBorder: borda(_erro),
      focusedErrorBorder: borda(_erro),
    );
  }

  Widget _label(String texto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _textoEscuro,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0FDFA), Color(0xFFC8F1E8)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              width: 350,
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFCFF5EC)),
                boxShadow: [
                  BoxShadow(
                    color: _teal.withValues(alpha: 0.20),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF00C9AD), _tealEscuro],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _teal.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        'C',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Classly',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _textoEscuro,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Bem-vindo de volta!',
                      style: TextStyle(fontSize: 14, color: Color(0xFF334155)),
                    ),

                    const SizedBox(height: 32),

                    // E-mail
                    _label('E-mail'),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      validator: (valor) {
                        final texto = (valor ?? '').trim();

                        if (texto.isEmpty) {
                          return 'Digite seu e-mail';
                        }

                        final emailValido =
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        if (!emailValido.hasMatch(texto)) {
                          return 'Digite um e-mail válido';
                        }

                        return null; // null = está tudo certo
                      },
                      decoration: _decoracaoCampo(
                        hint: 'seu@email.com',
                        icone: Icons.mail_outline,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Senha
                    _label('Senha'),
                    const SizedBox(height: 8),
                    TextFormField(
                      obscureText: _senhaOculta,
                      validator: (valor) {
                        if ((valor ?? '').isEmpty) {
                          return 'Digite sua senha';
                        }
                        return null;
                      },
                      decoration: _decoracaoCampo(
                        hint: '••••••••',
                        icone: Icons.lock_outline,
                        sufixo: IconButton(
                          icon: Icon(
                            _senhaOculta
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF94A3B8),
                          ),
                          onPressed: () =>
                              setState(() => _senhaOculta = !_senhaOculta),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'recuperar_senha');
                        },
                        child: const Text(
                          'Esqueci minha senha',
                          style: TextStyle(
                            color: _tealEscuro,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Botão Entrar (gradiente)
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00BFA5), _tealEscuro],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _teal.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // Só entra se e-mail e senha estiverem válidos
                          if (!_formKey.currentState!.validate()) return;

                          Navigator.pushNamed(context, 'inicio');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Divisor "ou"
                    Row(
                      children: const [
                        Expanded(child: Divider(color: _campoBorda)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'ou',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: _campoBorda)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Google
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: _campoBorda),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            // Troque por Image.asset('assets/google.png') se tiver o logo
                            Text(
                              'G',
                              style: TextStyle(
                                color: Color(0xFF4285F4),
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Continuar com Google',
                              style: TextStyle(
                                color: Color(0xFF334155),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Apple
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.apple, color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Continuar com Apple',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Criar conta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Não tem conta? ',
                          style: TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 13,
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, 'cadastro_usuario');
                            },
                            child: const Text(
                              'Criar conta',
                              style: TextStyle(
                                color: _tealEscuro,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
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
      ),
    );
  }
}