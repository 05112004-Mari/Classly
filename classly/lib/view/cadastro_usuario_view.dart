import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;
  bool _carregando = false;

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


  // Traduz o código de erro do Firebase para uma mensagem clara
  String _mensagemErro(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'O e-mail informado não é válido.';
      case 'weak-password':
        return 'Senha fraca. Use pelo menos $_minCaracteresSenha caracteres.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      case 'operation-not-allowed':
        return 'Cadastro por e-mail e senha não está habilitado no Firebase.';
      default:
        return 'Não foi possível criar a conta. Tente novamente.';
    }
  }

  Future<void> _cadastrar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _mostrarMensagem('Corrija os campos destacados.', erro: true);
      return;
    }

    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();

    setState(() => _carregando = true);

    try {
      // 1) Cria a conta no Firebase Authentication (e-mail e senha)
      final credencial =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _senhaController.text,
      );
      final usuario = credencial.user!;

      try {
        await usuario.updateDisplayName(nome);

        // 2) Salva os dados extras na coleção "usuarios" do Firestore.
        //    O id do documento é o uid do usuário. A senha NÃO é salva aqui.
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuario.uid)
            .set({
          'uid': usuario.uid,
          'nome': nome,
          'email': email,
          'criadoEm': FieldValue.serverTimestamp(),
        });
      } catch (_) {
        // Se não conseguiu salvar o perfil, desfaz a conta para não
        // ficar um usuário sem dados.
        await usuario.delete();
        rethrow;
      }

      SessaoUsuario.instancia.iniciar(nome: nome, email: email);

      if (!mounted) return;
      _mostrarMensagem('Cadastro realizado com sucesso!');
      Navigator.pushNamedAndRemoveUntil(context, 'inicio', (r) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _mostrarMensagem(_mensagemErro(e), erro: true);
    } catch (_) {
      if (!mounted) return;
      _mostrarMensagem(
        'Não foi possível concluir o cadastro. Tente novamente.',
        erro: true,
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
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
                            onFieldSubmitted: (_) {
                              if (!_carregando) _cadastrar();
                            },
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
                        onPressed: _carregando ? null : _cadastrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
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