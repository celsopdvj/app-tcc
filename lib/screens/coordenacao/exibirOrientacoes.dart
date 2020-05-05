import 'package:app_tcc/models/orientacoes.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExibirOrientacoes extends StatefulWidget {
  @override
  _ExibirOrientacoesState createState() => _ExibirOrientacoesState();
}

class _ExibirOrientacoesState extends State<ExibirOrientacoes> {
  final AuthService _auth = AuthService();
  
  bool loading = false;
  List<DataRow> newlist;
  List<DataCell> newListCell ;
  List<Orientacao> listaOrientacoes;

  List<Orientacao> criarListaOrientacoes(QuerySnapshot snapshot) {
    listaOrientacoes = new List<Orientacao>();
    for (DocumentSnapshot doc in snapshot.documents) {
      listaOrientacoes.add(new Orientacao(
          idOrientacao: doc.documentID,
          nomeAluno: doc.data['nomeAluno'],
          nomeProfessor: doc.data['nomeProfessor'],
          dia: doc.data['dia'],
          horario: doc['horario']));
    }
    return listaOrientacoes;
  }

  void deletarOrientacao(String id) async {
    setState(() {
      loading = true;
    });
    await DatabaseService().deletarOrientacao(id);
    setState(() {
      loading = false;
    });
  }

  List<DataRow> _createRows2(List<Orientacao> lista) {
    newlist = new List<DataRow>();
    for (Orientacao orientacao in lista) {
      newListCell = new List<DataCell>();
      newListCell.add(DataCell(Text(
        orientacao.nomeAluno,
        style: textStyle,
      )));
      newListCell.add(DataCell(Text(
        orientacao.nomeProfessor,
        style: textStyle,
      )));
      newListCell.add(DataCell(Text(
        orientacao.dia,
        style: textStyle,
      )));
      newListCell.add(DataCell(Text(
        orientacao.horario,
        style: textStyle,
      )));
      newListCell.add(DataCell(IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => new AlertDialog(
                    content: new Text('Deseja realmente deletar os dados dessa orientação?'),
                    actions: <Widget>[
                      new FlatButton(
                        textColor: Colors.red,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: new Text('Não'),
                      ),
                      new FlatButton(
                        textColor: Colors.white,
                        color: Colors.blue[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                        ),
                        onPressed: () async{
                          Navigator.of(context).pop(false);
                          await deletarOrientacao(orientacao.idOrientacao);
                          
                        },
                        child: new Text('Sim'),
                      )
                    ],
                  ));
        },
        icon: Icon(
          Icons.delete_forever,
          color: Colors.red,
        ),
      )));
      newlist.add(DataRow(cells: newListCell));
    }
    return newlist;
  }

  @override
  Widget build(BuildContext context) {
    return loading? Loading():Scaffold(
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
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Loading();
          listaOrientacoes = criarListaOrientacoes(snapshot.data);
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                key: Key('teste'),
                sortColumnIndex: 0,
                sortAscending: true,
                columns: <DataColumn>[
                  new DataColumn(
                    label: Text(
                      'Aluno(a)',
                      style: textStyle,
                    ),
                  ),
                  new DataColumn(
                      label: Text(
                    'Professor(a)',
                    style: textStyle,
                  )),
                  new DataColumn(
                      label: Text(
                    'Dia',
                    style: textStyle,
                  )),
                  new DataColumn(
                      label: Text(
                    'Horário',
                    style: textStyle,
                  )),
                  new DataColumn(
                      label: Text(
                    'Excluir',
                    style: textStyle,
                  ))
                ],
                rows: _createRows2(listaOrientacoes),
              ),
            ),
          );
        },
      ),
    );
  }
}
