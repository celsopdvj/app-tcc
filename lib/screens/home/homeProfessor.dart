import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:flutter/material.dart';

class HomeProfessor extends StatelessWidget {
  final User user;
  HomeProfessor({Key key, @required this.user}):super(key:key);

  @override
  Widget build(BuildContext context) {

    final AuthService _auth = AuthService();
    
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: Text('PUC GO TCC - Professor'),
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
      //Botões com funcionalidades dos professores
      body: Column(
        children: <Widget>[
          RaisedButton(
            color: Colors.blue[300],
            child: Text(
              "Pedidos de orientação",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/pedidosDeOrientacao', arguments: user);
            },
          ),
          RaisedButton(
            color: Colors.red[300],
            child: Text(
              "Botão 2",
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