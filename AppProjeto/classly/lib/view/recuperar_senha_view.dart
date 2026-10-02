import 'package:flutter/material.dart';

class RecuperarSenhaView extends StatefulWidget {
  const RecuperarSenhaView({super.key});

  @override
  State<RecuperarSenhaView> createState() => _RecuperarSenhaViewState();
}

class _RecuperarSenhaViewState extends State<RecuperarSenhaView> {
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