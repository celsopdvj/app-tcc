import 'package:app_tcc/models/defesas.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExibirDefesas extends StatefulWidget {
  @override
  _ExibirDefesasState createState() => _ExibirDefesasState();
}

class _ExibirDefesasState extends State<ExibirDefesas> {
  final AuthService _auth = AuthService();
  List<Defesas> listaDefesas = new List<Defesas>();
  

  List<Defesas> criarlistaDefesas(QuerySnapshot snapshot){
    for(DocumentSnapshot doc in snapshot.documents){
      listaDefesas.add(new Defesas(data: doc.data['data'], horario: doc['horario'], local: doc['sala'], disciplina: doc['disciplina'],nomeAluno: doc.data['nomeAluno'],titulo: doc.data['titulo'] ,orientador: doc.data['orientador'],));
    }
    return listaDefesas;
  }

  List<DataRow> _createRows2(List<Defesas> lista){
    List<DataRow> newlist = new List<DataRow>();
    for(Defesas defesas in lista){
      List<DataCell> newListCell = new List<DataCell>();
      newListCell.add(DataCell(Text(defesas.data, style: textStyle,)));
      newListCell.add(DataCell(Text(defesas.horario, style: textStyle,)));
      newListCell.add(DataCell(Text(defesas.local, style: textStyle,)));
      newListCell.add(DataCell(Text(defesas.disciplina, style: textStyle,)));
      newListCell.add(DataCell(Text(defesas.nomeAluno,style: textStyle,)));
      newListCell.add(DataCell(Text(defesas.titulo,style: textStyle,)));
      newListCell.add(DataCell(Text(defesas.orientador, style: textStyle,)));
      newlist.add(DataRow(cells: newListCell));
    }
    return newlist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Defesas'),
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
      stream: Firestore.instance.collection('defesa').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Loading();
        listaDefesas = criarlistaDefesas(snapshot.data);
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: new DataTable(
                sortColumnIndex: 0,
                sortAscending: true,
                columns: <DataColumn>[
                  new DataColumn(label: Text('Dia', style: textStyle,)),
                  new DataColumn(label: Text('Horário', style: textStyle,)),
                  new DataColumn(label: Text('Local', style: textStyle,)),
                  new DataColumn(label: Text('Disciplina', style: textStyle,)),
                  new DataColumn(label: Text('Aluno', style: textStyle,),),
                  new DataColumn(label: Text('Título', style: textStyle)),
                  new DataColumn(label: Text('Professor', style: textStyle,)),
                ],
                rows: _createRows2(listaDefesas),
            ),
          ),
        );
      },
      ),
    );
  }
}