import 'package:flutter/material.dart';

//RegisterDevice
class RegisterDevice extends StatefulWidget {
  const RegisterDevice({Key? key}) : super(key: key);

  @override
  State<RegisterDevice> createState() => _RegisterDeviceState();
}

class _RegisterDeviceState extends State<RegisterDevice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 120, 86, 255),
        centerTitle: true,
        title: Text('B2Epro - flutter', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text("SignUp"),
          ],
        ),
      ),
    );
  }
}
