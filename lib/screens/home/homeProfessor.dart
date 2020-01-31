import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:flutter/material.dart';

class HomeProfessor extends StatelessWidget {
  final User user;
  HomeProfessor({Key key, @required this.user}):super(key:key);

  @override
  Widget build(BuildContext context) {

    final AuthService _auth = AuthService();
    
    return Scaffold(
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
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ButtonTheme(
                minWidth: 300.0,
                height: 50.0,
                child: RaisedButton(
                  color: Colors.blue[300],
                  child: Text(
                    "Pedidos de orientação",
                    style: textStyle.copyWith(),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/pedidosDeOrientacao', arguments: user);
                  },
              ),
            ),
            SizedBox(height: 20.0),
            ButtonTheme(
                minWidth: 300.0,
                height: 50.0,
                child: RaisedButton(
                  color: Colors.red[300],
                  child: Text(
                    "Agendar defesa",
                    style: textStyle.copyWith(),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/agendarDefesa', arguments: user);
                  },
              ),
            )
          ],
        ),
      ),
    );
  }
}