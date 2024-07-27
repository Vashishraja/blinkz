import 'package:flutter/material.dart';

class BuildLogo extends StatelessWidget {
  const BuildLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Image.asset(
      'assets/logo.png', // Replace 'assets/logo.png' with the path to your logo image
      width: MediaQuery.of(context).size.width * 0.4,
    );
  }
}


