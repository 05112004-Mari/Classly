import 'package:flutter/material.dart';
 
class CadastroUsuarioView extends StatefulWidget {
  const CadastroUsuarioView({super.key});
 
  @override
  State<CadastroUsuarioView> createState() => _CadastroUsuarioViewState();
}
 
class _CadastroUsuarioViewState extends State<CadastroUsuarioView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(children: [
           
            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
 
            SizedBox(height: 10),
 
            TextField(
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
 
            TextField(
              decoration: InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
 
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
                ),
              ),
            SizedBox(height: 30),
 
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar Senha',
                border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
 
              ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(
                      context,
                      'inicio'
                  );
                },
                child: Text('Cadastrar'),
              ),
            ],
          ),
        )
      ),
    );
  }
}