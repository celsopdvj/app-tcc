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
          mainAxisAlignment: MainAxisAlignment.center,
          
          children: <Widget>[
            ButtonTheme(
              minWidth: 200.0,
              height: 50.0,
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(18.0),
                  ),
                color: Colors.blue[300],
                child: Text(
                    "Aluno",
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                onPressed: () {
                Navigator.pushNamed(context, '/registroAluno');
              }),
            ),
            SizedBox(height: 12,),
            ButtonTheme(
              minWidth: 200.0,
              height: 50.0,
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(18.0),
                  ),
                color: Colors.blue[300],
                child: Text(
                  "Professor",
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
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
