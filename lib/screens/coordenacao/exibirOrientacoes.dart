import 'package:app_tcc/models/orientacoes.dart';
import 'package:app_tcc/services/auth.dart';
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
  List<Orientacao> listaOrientacoes = new List<Orientacao>();
  
  List<Orientacao> criarListaOrientacoes(QuerySnapshot snapshot){
    for(DocumentSnapshot doc in snapshot.documents){
      listaOrientacoes.add(new Orientacao(nomeAluno: doc.data['nomeAluno'], nomeProfessor: doc.data['nomeProfessor'], dia: doc.data['dia'], horario: doc['horario']));
    }
    return listaOrientacoes;
  }

  List<DataRow> _createRows2(List<Orientacao> lista){
    List<DataRow> newlist = new List<DataRow>();
    for(Orientacao orientacao in lista){
      List<DataCell> newListCell = new List<DataCell>();
      newListCell.add(DataCell(Text(orientacao.nomeAluno,style: textStyle,)));
      newListCell.add(DataCell(Text(orientacao.nomeProfessor, style: textStyle,)));
      newListCell.add(DataCell(Text(orientacao.dia, style: textStyle,)));
      newListCell.add(DataCell(Text(orientacao.horario, style: textStyle,)));
      newlist.add(DataRow(cells: newListCell));
    }
    return newlist;
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
            label: Text('logout'),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: StreamBuilder(
      stream: Firestore.instance.collection('orientacao/turmas/orientacoes').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Loading();
        listaOrientacoes = criarListaOrientacoes(snapshot.data);
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: new DataTable(
                sortColumnIndex: 0,
                sortAscending: true,
                columns: <DataColumn>[
                  new DataColumn(label: Text('Aluno', style: textStyle,),),
                  new DataColumn(label: Text('Professor', style: textStyle,)),
                  new DataColumn(label: Text('Dia', style: textStyle,)),
                  new DataColumn(label: Text('Horário', style: textStyle,)),
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