import 'package:app_tcc/models/settingsFormOrientacao.dart';
import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PedidosDeOrientacao extends StatefulWidget {
  final User user;
  PedidosDeOrientacao({Key key, @required this.user}):super(key:key);
  @override
  _PedidosDeOrientacaoState createState() => _PedidosDeOrientacaoState();
}

class _PedidosDeOrientacaoState extends State<PedidosDeOrientacao> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DatabaseService banco = new DatabaseService();
  Map<String, bool> listaPedidosMarcados = new Map<String,bool>();
  String _alunoUid = '';
  String _alunoNome = '';
  String _alunoMatricula = '';
  String _alunoCurso = '';

  void aceitarPedido(){
    print(_alunoUid);
    User aluno = new User(uid: _alunoUid, nome: _alunoNome, matricula: _alunoMatricula, curso: _alunoCurso);
    Navigator.pushNamed(context, '/formularioOrientacao', arguments: ScreenArguments(widget.user, aluno));
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    ScrollController _controller = new ScrollController();
    
    return  Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Pedidos'),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('logout'),
            onPressed: () async {
              print(widget.user.uid);
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: StreamBuilder(
      stream: Firestore.instance.collection('pedidoPendente')
                                .where('validado' ,isEqualTo: true)
                                .where('uidProfessor', isEqualTo: widget.user.uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Loading();
        return Column(
          children: <Widget>[
            Expanded(
                child: new ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _controller,
                  children: snapshot.data.documents.map((document) {
                    return new RadioListTile(
                      groupValue: _alunoUid,
                      value: document['uidAluno'],
                      title: new Text(document['nomeAluno']),
                      onChanged: (val){
                        setState((){ 
                          _alunoUid = val.toString();
                          _alunoCurso = document['curso'];
                          _alunoMatricula = document['matricula'];
                          _alunoNome = document['nome'];
                        });
                        print(val);
                      },
                    );
                    }).toList(),
                  ),
              ),
              
              Align(
                  alignment: Alignment.bottomCenter,
                  child: RaisedButton(
                  color: Colors.blue,
                  child: Text("Aceitar",style: TextStyle(color: Colors.white)),
                  onPressed: aceitarPedido,
                ),
              ),
            ],
          );
        },
        ),
      );
  }
}