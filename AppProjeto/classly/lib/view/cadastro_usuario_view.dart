
import 'package:flutter/material.dart';

class CadastroUsuarioView extends StatefulWidget {
  const CadastroUsuarioView({super.key});

  @override
  State<CadastroUsuarioView> createState() => _CadastroUsuarioViewState();
}

class _CadastroUsuarioViewState extends State<CadastroUsuarioView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: SafeArea (
        child: Padding(
          padding: EdgeInsets.all (20),
          child: Column(
            children: [

               IconButton(
                icon: const Icon(Icons.arrow_back,
                size: 30),
                onPressed: () => Navigator.pop(context),
              ),

            ],
          ),
        ),
      ),
    );
  }
}