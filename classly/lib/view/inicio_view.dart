import 'package:flutter/material.dart';
import 'package:classly/widgets/barra_navegacao.dart';

class InicioView extends StatelessWidget {
  const InicioView({super.key});

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
          child: Stack(
            children: [
              // Conteudo principal
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    width: 360,
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
                    // child: ... conteúdo do card
                  ),
                ),
              ),

              // Perfil
              Positioned(
                top: 8,
                right: 16,
                child: Container(
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
                      Icons.person_outline,
                      color: Color(0xFF00B8A0),
                    ),
                    tooltip: 'Perfil',
                    onPressed: () {
                      Navigator.pushNamed(context, 'perfil');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Barra inferior reutilizável (aba 0 = Início, 1 = Kanban, 2 = Planejar, 3 = Aulas)
      bottomNavigationBar: const BarraNavegacao(currentIndex: 0),
    );
  }
}
