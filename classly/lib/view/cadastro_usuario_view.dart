import 'package:flutter/material.dart';
import 'package:classly/model/repositorio_usuarios_model.dart';
import 'package:classly/model/sessao_usuario_model.dart';

class CadastroUsuarioView extends StatefulWidget {
  const CadastroUsuarioView({super.key});

  @override
  State<CadastroUsuarioView> createState() => _CadastroUsuarioViewState();
}

class _CadastroUsuarioViewState extends State<CadastroUsuarioView> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;

  static const int _minCaracteresNome = 3;
  static const int _minCaracteresSenha = 6;

  static const Color _teal = Color(0xFF00B8A0);
  static const Color _campoFundo = Color(0xFFF8FAFC);
  static const Color _campoBorda = Color(0xFFE2E8F0);

  static final RegExp _regexEmail =
      RegExp(r'^[\w\.\-+]+@([\w\-]+\.)+[A-Za-z]{2,}$');

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }


  String? _validarNome(String? valor) {
    final nome = (valor ?? '').trim();
    if (nome.isEmpty) return 'Informe o seu nome.';
    if (nome.length < _minCaracteresNome) {
      return 'O nome deve ter pelo menos $_minCaracteresNome caracteres.';
    }
    return null;
  }

  String? _validarEmail(String? valor) {
    final email = (valor ?? '').trim();
    if (email.isEmpty) return 'Informe o seu e-mail.';
    if (!_regexEmail.hasMatch(email)) return 'Informe um e-mail válido.';
    return null;
  }

  String? _validarTelefone(String? valor) {
    final digitos = (valor ?? '').replaceAll(RegExp(r'\D'), '');
    if (digitos.isEmpty) return 'Informe o seu telefone.';
    if (digitos.length < 10 || digitos.length > 11) {
      return 'Informe um telefone válido com DDD.';
    }
    return null;
  }

  String? _validarSenha(String? valor) {
    final senha = valor ?? '';
    if (senha.isEmpty) return 'Informe uma senha.';
    if (senha.length < _minCaracteresSenha) {
      return 'A senha deve ter pelo menos $_minCaracteresSenha caracteres.';
    }
    return null;
  }

  String? _validarConfirmarSenha(String? valor) {
    final confirmacao = valor ?? '';
    if (confirmacao.isEmpty) return 'Confirme a sua senha.';
    if (confirmacao != _senhaController.text) {
      return 'As senhas não coincidem.';
    }
    return null;
  }


  void _cadastrar() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _mostrarMensagem('Corrija os campos destacados.', erro: true);
      return;
    }

    final repo = RepositorioUsuarios.instancia;
    final email = _emailController.text.trim();

    if (repo.emailExiste(email)) {
      _mostrarMensagem('Este e-mail já está cadastrado.', erro: true);
      return;
    }

    final nome = _nomeController.text.trim();
    repo.cadastrar(UsuarioCadastrado(
      nome: nome,
      email: email,
      telefone: _telefoneController.text.trim(),
      senha: _senhaController.text,
    ));

    SessaoUsuario.instancia.iniciar(nome: nome, email: email);

    _mostrarMensagem('Cadastro realizado com sucesso!');
    Navigator.pushNamedAndRemoveUntil(context, 'inicio', (r) => false);
  }

  void _mostrarMensagem(String texto, {bool erro = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: erro ? Colors.red.shade700 : _teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }


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
      enabledBorder: borda(_campoBorda),
      focusedBorder: borda(_teal),
      errorBorder: borda(Colors.red.shade700),
      focusedErrorBorder: borda(Colors.red.shade700),
      border: borda(_campoBorda),
    );
  }

  Widget _botaoVisibilidade(bool oculta, VoidCallback aoClicar) {
    return IconButton(
      icon: Icon(
        oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: const Color(0xFF94A3B8),
      ),
      onPressed: aoClicar,
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                width: 350,
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFB2DFDB)),
                  boxShadow: [
                    BoxShadow(
                      color: _teal.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Seta de voltar
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 28,
                          color: Color(0xFF0F172A),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

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
                          colors: [Color(0xFF00C9AD), Color(0xFF00796B)],
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

                    // Título
                    const SizedBox(height: 24),
                    const Text(
                      'Cadastre-se',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Nome
                          TextFormField(
                            controller: _nomeController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: _validarNome,
                            decoration: _decoracaoCampo(
                              hint: 'Nome',
                              icone: Icons.person_add,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // E-mail
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validarEmail,
                            decoration: _decoracaoCampo(
                              hint: 'seu@email.com',
                              icone: Icons.mail_outline,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Telefone
                          TextFormField(
                            controller: _telefoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            validator: _validarTelefone,
                            decoration: _decoracaoCampo(
                              hint: 'Telefone com DDD',
                              icone: Icons.phone_in_talk,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Senha
                          TextFormField(
                            controller: _senhaController,
                            obscureText: _senhaOculta,
                            textInputAction: TextInputAction.next,
                            validator: _validarSenha,
                            decoration: _decoracaoCampo(
                              hint: 'Senha',
                              icone: Icons.lock_outline,
                              sufixo: _botaoVisibilidade(
                                _senhaOculta,
                                () => setState(
                                    () => _senhaOculta = !_senhaOculta),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Confirmar senha
                          TextFormField(
                            controller: _confirmarSenhaController,
                            obscureText: _confirmarSenhaOculta,
                            textInputAction: TextInputAction.done,
                            validator: _validarConfirmarSenha,
                            onFieldSubmitted: (_) => _cadastrar(),
                            decoration: _decoracaoCampo(
                              hint: 'Confirmar senha',
                              icone: Icons.lock_outline,
                              sufixo: _botaoVisibilidade(
                                _confirmarSenhaOculta,
                                () => setState(() => _confirmarSenhaOculta =
                                    !_confirmarSenhaOculta),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botão cadastrar
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00BFA5), Color(0xFF00796B)],
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
                        onPressed: _cadastrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cadastrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
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