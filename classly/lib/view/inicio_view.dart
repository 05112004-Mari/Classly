import 'package:flutter/material.dart';

class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
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
            ],
          ),
        )
      ),
    );
  }
}