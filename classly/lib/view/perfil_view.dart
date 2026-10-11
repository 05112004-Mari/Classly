import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
 
class PerfilView extends StatefulWidget {
  const PerfilView({super.key});
 
  @override
  State<PerfilView> createState() => _PerfilViewState();
}
 
class _PerfilViewState extends State<PerfilView> {
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
            SizedBox(height: 30),
           
            Align(
              alignment: Alignment.center,
              child: Icon(Icons.manage_accounts, size: 120),
            ),
            ],
          ),
        )
      ),
    );
  }
}