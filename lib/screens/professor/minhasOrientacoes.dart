import 'package:app_tcc/models/orientacoes.dart';
import 'package:app_tcc/models/settingsEditarOrientacao.dart';
import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MinhasOrientacoes extends StatefulWidget {
  final User user;
  MinhasOrientacoes({Key key, @required this.user}) : super(key: key);
  @override
  _MinhasOrientacoesState createState() => _MinhasOrientacoesState();
}

class _MinhasOrientacoesState extends State<MinhasOrientacoes> {
  ScrollController _controller = new ScrollController(keepScrollOffset: true);
  final AuthService _auth = AuthService();
  List<Orientacao> listaOrientacoes = new List<Orientacao>();

  List<Orientacao> criarListaOrientacoes(QuerySnapshot snapshot) {
    for (DocumentSnapshot doc in snapshot.documents) {
      listaOrientacoes.add(new Orientacao(
          nomeAluno: doc.data['nomeAluno'],
          nomeProfessor: doc.data['nomeProfessor'],
          dia: doc.data['dia'],
          horario: doc['horario']));
    }
    return listaOrientacoes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orientações'),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('Sair', style: textStyle2.copyWith()),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('orientacao/turmas/orientacoes')
            .where('uidProfessor', isEqualTo: widget.user.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Loading();
          listaOrientacoes = criarListaOrientacoes(snapshot.data);
          return snapshot.data.documents.length == 0
              ? Column(children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                      child: Text(
                    "Você não possui orientandos.",
                    style: textStyle,
                  ))
                ])
              : ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            children: snapshot.data.documents.map((document) {
              return Padding(
                padding: EdgeInsets.all(15),
                child: Card(
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: ListTile(
                      title: Text("Orientando: " +
                          document.data['nomeAluno'].toString()),
                      subtitle:
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Turma: " + document.data['turma'].toString()),
                              Text("Horário: "+ document.data['dia']+" " +document.data['horario'])
                            ],
                          ),
                      isThreeLine: true,
                      onTap: (){
                        Orientacao orientacao = new Orientacao();
                        orientacao.curso = document['curso'];
                        orientacao.dia = document['dia'];
                        orientacao.horario = document['horario'];
                        orientacao.disciplina = document['disciplina'];
                        orientacao.matriculaAluno = document['matricula'];
                        orientacao.nomeAluno = document['nomeAluno'];
                        orientacao.nomeProfessor = document['nomeProfessor'];
                        orientacao.turma = document['turma'];
                        orientacao.uidOrientacao = document.documentID;
                        Navigator.pushNamed(context, '/editarOrientacao',arguments: ScreenArgumentsEditarOrientacao(user: widget.user,orientacao: orientacao));
                      }, //Editar Orientacao
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
