import 'package:flutter/material.dart';
 
class SobreView extends StatefulWidget {
  const SobreView({super.key});
 
  @override
  State<SobreView> createState() => _SobreViewState();
}
 
class _SobreViewState extends State<SobreView> {
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
                    'Sobre',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),


                  const SizedBox(height: 24),

                  // Informações sobre
                  _secao(
                    'Objetivo do aplicativo',
                    const Text(
                      'O Classly é um aplicativo para organizar a vida acadêmica '
                      'em um só lugar: cadastro da grade de aulas, planejamento '
                      'de estudos, mestas da semana e acompanhamento de tarefas.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF475569), 
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _secao(
                    'Equipe de desenvolvimento',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _integrante('Mariana Cristina dos Santos'),
                        _integrante('Maria Fernada Ribeiro Tavares'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _secao(
                    'Informações adicionais',
                    Column(
                      children: [
                        _linhaInfo('Disciplina', 'Programação para Dispositivos Moveis'),
                        _linhaInfo('Instituição', 'Fatec - Faculdade de Tecnologia de Ribeirão Preto'),
                        _linhaInfo('Professor', 'Rodrigo de Oliveira Plotze'),
                        _linhaInfo('Versão', '1.0.0'),
                      ],
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

Widget _secao(String titulo, Widget conteudo) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF0FDFA),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFB2DFDB)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF00796B),
          ),
        ),
        
        const SizedBox(height: 10),
        conteudo,
      ],
    ),
  );
}

Widget _integrante(String nome) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        const Icon(Icons.person_outline, size: 18, color: Color(0xFF00796B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            nome,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _linhaInfo(String rotulo, String valor) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            rotulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    ), 
  );
}