import 'package:app_tcc/shared/loading.dart';
import 'package:flutter/material.dart';

class VisualizarTCC extends StatefulWidget {
  final String url;
  VisualizarTCC({Key key, @required this.url}) : super(key: key);
  @override
  _VisualizarTCCState createState() => _VisualizarTCCState();
}

class _VisualizarTCCState extends State<VisualizarTCC> {
  bool loading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return loading ? Loading(): 
      Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0.0,
        ),
        body: 
  }
}