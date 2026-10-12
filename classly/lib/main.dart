import 'package:classly/view/aulas_view.dart';
import 'package:classly/view/kanban_view.dart';
import 'package:classly/view/planejar_view.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/material.dart';

import 'view/cadastro_usuario_view.dart';
import 'view/login_view.dart';
import 'view/perfil_view.dart';
import 'view/recuperar_senha_view.dart';
import 'view/sobre_view.dart';
import 'view/inicio_view.dart';

void main() {
  runApp(DevicePreview(builder: (context) => const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App',

      //
      // ROTAS
      //
      initialRoute: 'login',
      routes: {
        'login': (context) => const LoginView(),
        'cadastro_usuario': (context) => const CadastroUsuarioView(),
        'perfil': (context) => const PerfilView(),
        'recuperar_senha': (context) => const RecuperarSenhaView(),
        'sobre': (context) => const SobreView(),
        'inicio': (context) => const InicioView(),
        'kanban':(context) => const KanbanView(),
        'planejar':(context) => const PlanejarView(),
        'aulas':(context) => const AulasView(),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => LoginView(),
        );
      },
    );
  }
}
