import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:flutter/material.dart';

class Horario extends StatefulWidget {
  @override
  _HorarioState createState() => _HorarioState();
}

class _HorarioState extends State<Horario> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    final AuthService _auth = AuthService();
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Horários'),
        elevation: 0.0,
        
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          SizedBox(height: 20.0),
          RaisedButton(
            color: Colors.blue,
            child: Text("Confirmar", style: TextStyle(color: Colors.white),),
            onPressed: () async {
              //Navigator.pushReplacementNamed(context, '/horarios', arguments: result);
            }
          )
        ])
      )
    );
  }
}