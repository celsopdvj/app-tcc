import 'package:flutter/material.dart';

class TipoUsuario extends StatefulWidget {
  @override
  _TipoUsuarioState createState() => _TipoUsuarioState();
}

class _TipoUsuarioState extends State<TipoUsuario> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 0.0,
          title: Text('Tipo de usuário')
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          
          children: <Widget>[
            ButtonTheme(
              minWidth: 200.0,
              height: 50.0,
              child: MaterialButton(
                color: Colors.blue[300],
                child: Text(
                    "Aluno",
                    style: TextStyle(color: Colors.white, fontSize: 30.0),
                ),
                onPressed: () {
                Navigator.pushNamed(context, '/registroAluno');
              }),
            ),
            ButtonTheme(
              minWidth: 200.0,
              height: 50.0,
              child: MaterialButton(
                color: Colors.blue[300],
                child: Text(
                  "Professor",
                  style: TextStyle(color: Colors.white, fontSize: 30.0),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/registroProfessor');
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
