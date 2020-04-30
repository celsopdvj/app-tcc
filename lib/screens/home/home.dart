import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final User user;
  Home({Key key, @required this.user}) : super(key: key);

  final DatabaseService banco = new DatabaseService();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    String orientador;

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('ECEC TCC'),
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text(
                'Sair',
                style: textStyle2.copyWith(),
              ),
              onPressed: () async {
                print(user.uid);
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
            )
          ],
        ),
        //Botões com funcionalidades dos alunos
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20.0),
                ButtonTheme(
                  minWidth: 300.0,
                  height: 50.0,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                    ),
                    color: Colors.blue[300],
                    child: Text(
                      "Enviar convite de orientação",
                      style: textStyle2.copyWith(),
                    ),
                    onPressed: () async {
                      orientador = await banco.getOrientador(user.uid);
                      if (orientador != "") {
                        //mostrar "Já possui orientador"
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: new Text("Já possui orientador!"),
                          duration: Duration(seconds: 3),
                          backgroundColor: Colors.red,
                        ));
                      } else if (user.curso ==
                              "Análise e Desenvolvimento de Sistemas" ||
                          user.curso == "Química") {
                        showDialog(
                            context: context,
                            builder: (context) => new AlertDialog(
                                  content: new Text(
                                      'Este curso não possui disciplinas de TCC!'),
                                  actions: <Widget>[
                                    new FlatButton(
                                      textColor: Colors.white,
                                      color: Colors.blue[300],
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(18.0),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: new Text('Ok'),
                                    ),
                                  ],
                                ));
                      } else {
                        Navigator.pushNamed(context, '/enviarOrientacao',
                            arguments: user);
                      }
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                ButtonTheme(
                  minWidth: 300.0,
                  height: 50.0,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                    ),
                    color: Colors.blue[300],
                    child: Text(
                      "Exibir Defesas",
                      style: textStyle2.copyWith(),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/exibirDefesas');
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                ButtonTheme(
                  minWidth: 300.0,
                  height: 50.0,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                    ),
                    color: Colors.blue[300],
                    child: Text(
                      "Ver TCCs",
                      style: textStyle2.copyWith(),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/exibirTCC');
                    },
                  ),
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
