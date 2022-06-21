import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  WorkButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: 200,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: const Color.fromARGB(255, 120, 86, 255),
              onPrimary: Colors.white),
          onPressed: onPressed,
          child: Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
