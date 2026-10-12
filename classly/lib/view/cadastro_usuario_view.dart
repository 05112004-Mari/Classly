import 'package:flutter/material.dart';
 
class CadastroUsuarioView extends StatefulWidget {
  const CadastroUsuarioView({super.key});
 
  @override
  State<CadastroUsuarioView> createState() => _CadastroUsuarioViewState();
}
 
class _CadastroUsuarioViewState extends State<CadastroUsuarioView> {
    bool _senhaOculta = true;

  static const Color _teal = Color(0xFF00B8A0);
  static const Color _campoFundo = Color(0xFFF8FAFC);
  static const Color _campoBorda = Color(0xFFE2E8F0);

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
      border: borda(_campoBorda),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: Container (
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
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
                      color: const Color(0xFF00B8A0).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                 ],
               ), 

              //seta de voltar
               child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                      size: 28,
                      color:  Color(0XFF0F172A),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),  
                  ),

                  //Logo
                  Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xff00C9AD), Color(0xFF00796B)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B8A0).withValues(alpha: 0.35),
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

                  //Titulo
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

                  //nome
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Nome',
                      hintStyle: const TextStyle(color: Color(0xFF94A3BB)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      prefixIcon: const Icon(
                        Icons.person_add,
                        color: Color(0xFF94A3B8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF00B8A0)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  //email
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'seu@email.com',
                      hintStyle: const TextStyle(color: Color(0xFF94A3BB)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      prefixIcon: const Icon(
                        Icons.mail_outline,
                        color: Color(0xFF94A3B8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF00B8A0)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  //telefone
                  TextField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Telefone',
                      hintStyle: const TextStyle(color: Color(0xFF94A3BB)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      prefixIcon: const Icon(
                        Icons.phone_in_talk,
                        color: Color(0xFF94A3B8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF00B8A0)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),


                  // Senha
                  const SizedBox(height: 8),
                  TextField(
                    obscureText: _senhaOculta,
                    decoration: _decoracaoCampo(
                      hint: 'Senha',
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

                  const SizedBox(height: 24),

                  // Senha
                  const SizedBox(height: 8),
                  TextField(
                    obscureText: _senhaOculta,
                    decoration: _decoracaoCampo(
                      hint: 'Confirmar senha',
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

                  const SizedBox(height: 24),

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
                          color: const Color(0xFF00B8A0).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: (){
                        Navigator.pushNamed(
                          context,
                          'inicio',
                        );
                      },
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