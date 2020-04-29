import 'package:app_tcc/models/settingsFormOrientacao.dart';
import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EnviarTCC extends StatefulWidget {
  final User user;
  EnviarTCC({Key key, @required this.user}) : super(key: key);
  @override
  _EnviarTCCState createState() => _EnviarTCCState();
}

class _EnviarTCCState extends State<EnviarTCC> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DatabaseService banco = new DatabaseService();
  String _alunoUid = '';
  bool loading = false;

  void enviarTCC() async {
    setState(() {
      loading = true;
    });
    if (_alunoUid != '') {
      if (await banco.jaEnviouTCC(_alunoUid)) {
        setState(() {
          loading = false;
        });
        showDialog(
            context: context,
            builder: (context) => new AlertDialog(
                  content: new Text(
                      'Já foi enviado o TCC deste(a) aluno(a). Deseja substituí-lo?'),
                  actions: <Widget>[
                    new FlatButton(
                      textColor: Colors.white,
                      color: Colors.red[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: new Text('Cancelar'),
                    ),
                    new FlatButton(
                      textColor: Colors.white,
                      color: Colors.blue[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                      ),
                      onPressed: () async {
                        User aluno = await banco.getUser(_alunoUid);
                        Navigator.of(context).pop(false);
                        Navigator.pushNamed(context, '/formularioEnviarTCC',
                            arguments: ScreenArguments(
                                professor: widget.user, aluno: aluno));
                        _alunoUid = '';
                      },
                      child: new Text('Confirmar'),
                    )
                  ],
                ));
      } else {
        User aluno = await banco.getUser(_alunoUid);
        setState(() {
          loading = false;
        });
        Navigator.pushNamed(context, '/formularioEnviarTCC',
            arguments: ScreenArguments(professor: widget.user, aluno: aluno));
        _alunoUid = '';
      }
    }
  }

  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    ScrollController _controller = new ScrollController(keepScrollOffset: true);

    return loading
        ? Loading()
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Escolha o orientando'),
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
            body: StreamBuilder(
              stream: Firestore.instance
                  .collection('usuario')
                  .where('orientador', isEqualTo: widget.user.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Loading();
                return snapshot.data.documents.length == 0
                    ? Column(children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                            child: Text(
                          "Não possui alunos orientandos!",
                          style: textStyle,
                        ))
                      ])
                    : Column(
                        children: <Widget>[
                          Expanded(
                            child: new ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: _controller,
                              children: snapshot.data.documents.map((document) {
                                return new RadioListTile(
                                  groupValue: _alunoUid,
                                  value: document.documentID,
                                  title: new Text(document['nome']),
                                  onChanged: (val) {
                                    setState(() {
                                      _alunoUid = val.toString();
                                    });
                                    print(val);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                ButtonTheme(
                                  minWidth: 300.0,
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(18.0),
                                    ),
                                    color: Colors.blue,
                                    child: Text("Confirmar",
                                        style: TextStyle(color: Colors.white)),
                                    onPressed: enviarTCC,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      );
              },
            ),
          );
  }
}
