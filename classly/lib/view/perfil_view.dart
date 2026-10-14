import 'package:flutter/material.dart';
import 'package:classly/model/sessao_usuario_model.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  static const int _minCaracteresNome = 3;
  static const Color _verde = Color(0xFF00B8A0);
  static const Color _borda = Color(0xFFB2DFDB);
  static const Color _texto = Color(0xFF0F172A);

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();

  bool _salvando = false;

  final _sessao = SessaoUsuario.instancia;

  @override
  void initState() {
    super.initState();
    if (!_sessao.autenticado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, 'login', (r) => false);
      });
    }
    _carregarDados();
  }

  void _carregarDados() {
    _nomeController.text = _sessao.nome.value;
    _emailController.text = _sessao.email;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validarNome(String? valor) {
    final nome = (valor ?? '').trim();
    if (nome.isEmpty) {
      return 'Informe o seu nome.';
    }
    if (nome.length < _minCaracteresNome) {
      return 'O nome deve ter pelo menos $_minCaracteresNome caracteres.';
    }
    return null;
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      _mostrarMensagem('Corrija os campos destacados.', erro: true);
      return;
    }

    setState(() => _salvando = true);
    try {
      final novoNome = _nomeController.text.trim();

      await Future.delayed(const Duration(milliseconds: 400));

      // Atualiza o nome
      _sessao.nome.value = novoNome;
      _nomeController.text = novoNome;

      if (!mounted) return;
      _mostrarMensagem('Perfil atualizado com sucesso!');
    } catch (e) {
      if (!mounted) return;
      _mostrarMensagem('Não foi possível atualizar o perfil.', erro: true);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _cancelar() {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();
    setState(_carregarDados);
  }

  void _mostrarMensagem(String texto, {bool erro = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: erro ? Colors.red.shade700 : _verde,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  InputDecoration _decoracao(String label, IconData icone,
      {bool desabilitado = false}) {
    OutlineInputBorder borda(Color cor) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cor),
        );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icone, color: desabilitado ? Colors.grey : _verde),
      filled: true,
      fillColor: desabilitado ? const Color(0xFFF1F5F9) : Colors.white,
      enabledBorder: borda(_borda),
      disabledBorder: borda(const Color(0xFFE2E8F0)),
      focusedBorder: borda(_verde),
      errorBorder: borda(Colors.red.shade700),
      focusedErrorBorder: borda(Colors.red.shade700),
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
                  border: Border.all(color: _borda),
                  boxShadow: [
                    BoxShadow(
                      color: _verde.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Seta de voltar
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              size: 28, color: _texto),
                          onPressed: () => Navigator.pop(context),
                        ),

                        // Botão Sobre
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: _borda),
                            boxShadow: [
                              BoxShadow(
                                color: _verde.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.info, color: _verde),
                            tooltip: 'Sobre',
                            onPressed: () =>
                                Navigator.pushNamed(context, 'sobre'),
                          ),
                        ),
                      ],
                    ),

                    // conteudo tela
                    const SizedBox(height: 8),
                    ValueListenableBuilder<String>(
                      valueListenable: _sessao.nome,
                      builder: (_, nome, __) {
                        final inicial =
                            nome.trim().isEmpty ? '?' : nome.trim()[0].toUpperCase();
                        return CircleAvatar(
                          radius: 42,
                          backgroundColor: _verde,
                          child: Text(
                            inicial,
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Meu Perfil',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _texto,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Nome (editável)
                          TextFormField(
                            controller: _nomeController,
                            enabled: !_salvando,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            validator: _validarNome,
                            onFieldSubmitted: (_) => _salvar(),
                            decoration:
                                _decoracao('Nome', Icons.person_outline),
                          ),
                          const SizedBox(height: 16),

                          // E-mail (somente leitura)
                          TextFormField(
                            controller: _emailController,
                            enabled: false,
                            decoration: _decoracao(
                              'E-mail',
                              Icons.email_outlined,
                              desabilitado: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Salvar
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _salvando ? null : _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _verde,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _salvando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Salvar alterações',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Cancelar 
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _salvando ? null : _cancelar,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _texto,
                          side: const BorderSide(color: _borda),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Cancelar'),
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