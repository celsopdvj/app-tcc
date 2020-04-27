import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:flutter/material.dart';

class HomeProfessor extends StatefulWidget {
  final User user;
  HomeProfessor({Key key, @required this.user}) : super(key: key);
  @override
  _HomeProfessorState createState() => _HomeProfessorState();
}

class _HomeProfessorState extends State<HomeProfessor> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

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
              label: Text('Sair', style: textStyle2.copyWith()),
              onPressed: () async {
                print(widget.user.uid);
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
                  shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(18.0),
                  ),
                  color: Colors.blue[300],
                  child: Text(
                    "Pedidos de orientação",
                    style: textStyle2.copyWith(),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/pedidosDeOrientacao',
                        arguments: widget.user);
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
                    "Agendar defesa",
                    style: textStyle2.copyWith(),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/defesasAgendadas',
                        arguments: widget.user);
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
                    "Convites de banca de defesa",
                    style: textStyle2.copyWith(),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/convitesDefesa',
                        arguments: widget.user);
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
                    "Enviar TCC",
                    style: textStyle2.copyWith(),
                  ),
                  onPressed: () async {
                    Navigator.pushNamed(context, '/enviarTCC',
                        arguments: widget.user);
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
                    "Gerar ata de defesa",
                    style: textStyle2.copyWith(),
                  ),
                  onPressed: () async {
                    Navigator.pushNamed(context, '/gerarAtaDefesa',
                        arguments: widget.user);
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
                    "Editar horários das aulas",
                    style: textStyle2.copyWith(),
                  ),
                  onPressed: () async {
                    Navigator.pushNamed(context, '/editarHorario',
                        arguments: widget.user);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
