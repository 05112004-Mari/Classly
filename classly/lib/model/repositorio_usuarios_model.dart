class UsuarioCadastrado {
  final String nome;
  final String email;
  final String telefone;
  final String senha;

  UsuarioCadastrado({
    required this.nome,
    required this.email,
    required this.telefone,
    required this.senha,
  });
}

class RepositorioUsuarios {
  RepositorioUsuarios._();
  static final RepositorioUsuarios instancia = RepositorioUsuarios._();

  final Map<String, UsuarioCadastrado> _usuarios = {};

  bool emailExiste(String email) =>
      _usuarios.containsKey(email.trim().toLowerCase());

  void cadastrar(UsuarioCadastrado usuario) {
    _usuarios[usuario.email.trim().toLowerCase()] = usuario;
  }

  UsuarioCadastrado? buscarPorEmail(String email) =>
      _usuarios[email.trim().toLowerCase()];
}