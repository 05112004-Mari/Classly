import 'package:flutter/material.dart';

class BarraNavegacao extends StatelessWidget {
  // Índice da aba da tela atual (0 = Início, 1 = Kanban, 2 = Planejar, 3 = Aulas)
  final int currentIndex;

  const BarraNavegacao({super.key, required this.currentIndex});

  static const List<String> _rotas = [
    'inicio',
    'kanban',
    'planejar',
    'aulas',
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return; // já está nessa tela

        Navigator.pushReplacementNamed(context, _rotas[index]);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF00B8A0),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          activeIcon: Icon(Icons.grid_view),
          label: 'Kanban',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Planejar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book_outlined),
          activeIcon: Icon(Icons.book),
          label: 'Aulas',
        ),
      ],
    );
  }
}