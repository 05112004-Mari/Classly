import 'package:flutter/foundation.dart';

class SessaoUsuario {
  SessaoUsuario._();
  static final SessaoUsuario instancia = SessaoUsuario._();

  /// Preencha no login com os dados reais do usuário autenticado.
  final ValueNotifier<String> nome = ValueNotifier<String>('');
  String email = '';

  bool get autenticado => email.isNotEmpty;

  void iniciar({required String nome, required String email}) {
    this.email = email;
    this.nome.value = nome;
  }

  void encerrar() {
    email = '';
    nome.value = '';
  }
}