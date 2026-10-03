import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold (
       backgroundColor: const Color.fromARGB(255, 191, 253, 253),
      body: SafeArea (
        child: Padding(
          padding: EdgeInsets.all (20),
          child: Column(
            children: [

            Icon(Icons.copyright, size: 90),
            SizedBox(height: 30),

            TextField(
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 10),

            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 10),

            Align(
              alignment: AlignmentGeometry.centerRight,
              child: TextButton(
                onPressed: () {


                //Fazer ir para a pagina de recuperar senha

                Navigator.pushNamed(
                  context, 
                  'recuperar_senha',
                );

              },
                child: Text('Esqueceu a senha?'),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {}, 
              child: Text('entrar'),
            ),
            SizedBox(height: 40),

            TextButton(
              onPressed: () {

                Navigator.pushNamed(
                  context, 
                  'cadastro_usuario',
                );


              },
              child: Text(
                'Ainda não tem conta? Cadastre-se.'
              ),
            ),


            
           ],
          ),
        ),
      ),
    );
  }
}