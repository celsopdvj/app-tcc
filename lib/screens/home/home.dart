import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final User user;
  Home({Key key, @required this.user}):super(key:key);


  
  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: Text('PUC GO TCC - Aluno'),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('logout'),
            onPressed: () async {
              print(user.uid);
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      //Botões com funcionalidades dos alunos
      body: Column(
        children: <Widget>[
          RaisedButton(
            color: Colors.blue[300],
            child: Text(
              "Enviar convite de orientação",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/enviarOrientacao', arguments: user);
            },
          ),
          RaisedButton(
            color: Colors.red[300],
            child: Text(
              "Exibir defesas",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              
            },
          )
        ],
      ),
    );
  }
}
