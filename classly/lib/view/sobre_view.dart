import 'package:flutter/material.dart';
 
class SobreView extends StatefulWidget {
  const SobreView({super.key});
 
  @override
  State<SobreView> createState() => _SobreViewState();
}
 
class _SobreViewState extends State<SobreView> {
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

              //seta de voltar
               child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                      size: 28,
                      color:  Color(0XFF0F172A),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),  
                  ),

                  //Logo
                  Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xff00C9AD), Color(0xFF00796B)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B8A0).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),

                        ),
                      ],
                    ),

                    child: const Text(
                      'C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,

                      ),
                    ),
                  ),

                  //Titulo
                  const SizedBox(height: 24),
                  const Text(
                    'Sobre',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),


                  const SizedBox(height: 24),

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