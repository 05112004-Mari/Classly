import 'package:flutter/material.dart';
 
class PerfilView extends StatefulWidget {
  const PerfilView({super.key});
 
  @override
  State<PerfilView> createState() => _PerfilViewState();
}
 
class _PerfilViewState extends State<PerfilView> {
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

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Linha superior: seta de voltar + botão Sobre
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Seta de voltar
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 28,
                          color: Color(0xFF0F172A),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),

                      // Botão Sobre
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFB2DFDB)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00B8A0).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.info,
                            color: Color(0xFF00B8A0),
                          ),
                          tooltip: 'Sobre',
                          onPressed: () {
                            Navigator.pushNamed(context, 'sobre');
                          },
                        ),
                      ),
                    ],
                  ),

                  // conteudo tela
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