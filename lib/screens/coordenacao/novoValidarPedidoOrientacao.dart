import 'package:app_tcc/models/pedidoOrientacao.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NovoValidarPedido extends StatefulWidget {
  @override
  _NovoValidarPedidoState createState() => _NovoValidarPedidoState();
}

class _NovoValidarPedidoState extends State<NovoValidarPedido> {
  final AuthService _auth = AuthService();
  DatabaseService banco = new DatabaseService();
  List<PedidoOrientacao> listaPedidos = new List<PedidoOrientacao>();
  bool value = false;
  Map<String, bool> listaPedidosMarcados = new Map<String, bool>();
  bool loading = false;
  bool _sortDisciplinaAsc = true;
  bool _sortNomeAlunoAsc = true;
  bool _sortOrientadorAsc = true;
  bool _sortAsc = true;
  int _sortColumnIndex;
  bool listaCriada = false;

  void criarListaPedidos(var snapshot)  {
    for (DocumentSnapshot doc in snapshot.documents) {
      listaPedidos.add(new PedidoOrientacao(
          id: doc.documentID,
          disciplina: doc.data['disciplina'],
          nomeAluno: doc.data['nomeAluno'],
          nomeProfessor: doc.data['nomeProfessor']));
    }
    //return (lista);
  }

  void validarPedidos() {
    print(listaPedidosMarcados);
    listaPedidosMarcados.forEach((k, v) {
      if (v) {
        banco.validaPedidoPendente(k);
        listaPedidos.removeWhere((pedido)=>pedido.id==k);
      }
    });
    listaPedidosMarcados.clear();
    setState(() {});
  }

  void recusarPedidos() {
    print(listaPedidosMarcados);
    listaPedidosMarcados.forEach((k, v) {
      if (v) {
        banco.deletarPedido(k);
        listaPedidos.removeWhere((pedido)=>pedido.id==k);
      }     
    });
    listaPedidosMarcados.clear();
    setState(() {});
  }

  void checksAll(bool val) {
    setState(() {
      listaPedidos.forEach((pedido) {
        value = val;
        listaPedidosMarcados[pedido.id] = val;
      });
    });
    print(listaPedidosMarcados);
  }

  List<DataRow> _createRows2(List<PedidoOrientacao> lista) {
    List<DataRow> newlist = new List<DataRow>();
    for (PedidoOrientacao pedido in lista) {
      List<DataCell> newListCell = new List<DataCell>();
      newListCell.add(DataCell(Text(
        pedido.disciplina,
        style: textStyle,
      )));
      newListCell.add(DataCell(Text(
        pedido.nomeAluno,
        style: textStyle,
      )));
      newListCell.add(DataCell(Text(
        pedido.nomeProfessor,
        style: textStyle,
      )));
      newListCell.add(DataCell(Checkbox(
          key: Key(pedido.id),
          value: listaPedidosMarcados[pedido.id] == null
              ? false
              : listaPedidosMarcados[pedido.id],
          onChanged: (bool val) {
            setState(() {
              listaPedidosMarcados[pedido.id] = val;
              print(listaPedidosMarcados);
            });
          })));
      newlist.add(DataRow(cells: newListCell));
    }
    return newlist;
  }

  void sortDisciplina(int columnIndex, bool sortAscending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sortAsc = _sortDisciplinaAsc = sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAsc = _sortDisciplinaAsc;
      }
      listaPedidos.sort((a, b) => a.disciplina.compareTo(b.disciplina));
      if (!sortAscending) {
        listaPedidos = listaPedidos.reversed.toList();
      }
    });
  }

  void sortAluno(int columnIndex, bool sortAscending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sortAsc = _sortNomeAlunoAsc = sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAsc = _sortNomeAlunoAsc;
      }
      listaPedidos.sort((a, b) => a.nomeAluno.compareTo(b.nomeAluno));
      if (!sortAscending) {
        listaPedidos = listaPedidos.reversed.toList();
      }
    });
  }

  void sortProfessor(int columnIndex, bool sortAscending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sortAsc = _sortOrientadorAsc = sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAsc = _sortOrientadorAsc;
      }
      listaPedidos.sort((a, b) => a.nomeProfessor.compareTo(b.nomeProfessor));
      if (!sortAscending) {
        listaPedidos = listaPedidos.reversed.toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {


    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text('Pedidos'),
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
                    .collection('pedidoPendente')
                    .where('validado', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Loading();
                  if(!listaCriada){
                    criarListaPedidos(snapshot.data);
                    listaCriada = true;
                  }
                    

                  return snapshot.data.documents.length == 0
                      ? Column(children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                              child: Text(
                            "Não há pedidos de orientação para validar!",
                            style: textStyle,
                          ))
                        ])
                      : Column(
                          children: <Widget>[
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: new DataTable(
                                    sortColumnIndex: _sortColumnIndex,
                                    sortAscending: _sortAsc,
                                    columns: <DataColumn>[
                                      new DataColumn(
                                        onSort: (columnIndex, sortAscending)=>sortDisciplina(columnIndex,sortAscending),
                                        label: Text(
                                          'Disciplina',
                                          style: textStyle,
                                        ),
                                      ),
                                      new DataColumn(
                                        onSort: (columnIndex, sortAscending)=>sortAluno(columnIndex,sortAscending),
                                          label: Text(
                                        'Aluno(a)',
                                        style: textStyle,
                                      )),
                                      new DataColumn(
                                        onSort: (columnIndex, sortAscending)=>sortProfessor(columnIndex,sortAscending),
                                          label: Text(
                                        'Orientador(a)',
                                        style: textStyle,
                                      )),
                                      new DataColumn(
                                          label: Checkbox(
                                        value: value,
                                        onChanged: checksAll,
                                      )),
                                    ],
                                    rows: _createRows2(listaPedidos),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(18.0),
                                      ),
                                      color: Colors.blue,
                                      child: Text("Validar",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onPressed: () {
                                        setState(() => loading = true);
                                        validarPedidos();
                                        setState(() => loading = false);
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                new AlertDialog(
                                                  content: new Text(
                                                      'Pedidos validados!'),
                                                  actions: <Widget>[
                                                    new FlatButton(
                                                      textColor: Colors.white,
                                                      color: Colors.blue[300],
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(18.0),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(false);
                                                      },
                                                      child: new Text('Ok'),
                                                    ),
                                                  ],
                                                ));
                                      }),
                                  RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(18.0),
                                      ),
                                      color: Colors.white,
                                      child: Text("Recusar",
                                          style: TextStyle(color: Colors.red)),
                                      onPressed: () {
                                        setState(() => loading = true);
                                        recusarPedidos();
                                        setState(() => loading = false);
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                new AlertDialog(
                                                  content: new Text(
                                                      'Pedidos recusados!'),
                                                  actions: <Widget>[
                                                    new FlatButton(
                                                      textColor: Colors.white,
                                                      color: Colors.blue[300],
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(18.0),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(false);
                                                      },
                                                      child: new Text('Ok'),
                                                    ),
                                                  ],
                                                ));
                                      }),
                                ],
                              ),
                            ),
                          ],
                        );
                }));
  }
}
