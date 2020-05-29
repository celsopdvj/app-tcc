import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
          child: Container(
        color: Colors.white,
        child: Center(
          child: SpinKitChasingDots(
            color: Colors.blue[300],
            size: 80.0,
            )
        ),
      ),
    );
  }
}