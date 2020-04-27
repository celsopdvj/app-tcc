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
  Map<String, bool> listaPedidosMarcados = new Map<String,bool>();
  bool loading = false;

  @override
  void initState(){
    super.initState();
    criarListaPedidos();
  }

  void criarListaPedidos() async{
    QuerySnapshot snapshot = await Firestore.instance.collection('pedidoPendente').where('validado' ,isEqualTo: false).getDocuments();
    for(DocumentSnapshot doc in snapshot.documents){
      listaPedidos.add(new PedidoOrientacao(id:doc.documentID,disciplina: doc.data['disciplina'],nomeAluno: doc.data['nomeAluno'], nomeProfessor: doc.data['nomeProfessor']));
    }
    setState(() {});
  }

  void validarPedidos(){
    print(listaPedidosMarcados);
    listaPedidosMarcados.forEach((k,v){
      if(v){
        banco.validaPedidoPendente(k);
      }
    });
    listaPedidosMarcados.clear();
    setState(() {
      
    });
  }

  void recusarPedidos(){
    print(listaPedidosMarcados);
    listaPedidosMarcados.forEach((k,v){
      if(v){
        banco.deletarPedido(k);
      }
    });
    listaPedidosMarcados.clear();
    setState(() {
      
    });
  }

  void checksAll(bool val){
    setState(() {
      listaPedidos.forEach((pedido){
        value = val;
        listaPedidosMarcados[pedido.id] = val;
      });
    });
    print(listaPedidosMarcados);
  }

  List<DataRow> _createRows2(QuerySnapshot snap){
    List<PedidoOrientacao> lista = new List<PedidoOrientacao>();
    snap.documents.forEach((doc){
      lista.add(new PedidoOrientacao(id: doc.documentID, disciplina: doc.data['disciplina'], nomeAluno: doc.data['nomeAluno'], nomeProfessor: doc.data['nomeProfessor']));
    });
    List<DataRow> newlist = new List<DataRow>();
    for(PedidoOrientacao pedido in lista){
      List<DataCell> newListCell = new List<DataCell>();
      newListCell.add(DataCell(Text(pedido.disciplina, style: textStyle,)));
      newListCell.add(DataCell(Text(pedido.nomeAluno,style: textStyle,)));
      newListCell.add(DataCell(Text(pedido.nomeProfessor, style: textStyle,)));
      newListCell.add(DataCell(Checkbox(
        key: Key(pedido.id),
        value: listaPedidosMarcados[pedido.id] == null ? false : listaPedidosMarcados[pedido.id],
        onChanged: (bool val){
          setState(() {
            listaPedidosMarcados[pedido.id] = val;
            print(listaPedidosMarcados);
          });
        })));
      newlist.add(DataRow(cells: newListCell));
    }
    return newlist;
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading(): Scaffold(
      appBar: AppBar(
        title: Text('Pedidos'),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('Sair'),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: 
         StreamBuilder<Object>(
           stream: Firestore.instance.collection('pedidoPendente').where('validado' ,isEqualTo: false).snapshots(),
           builder: (context, snapshot) {
             if (!snapshot.hasData) return Loading();
             return Column(
               children: <Widget>[
                 Expanded(
                    child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: new DataTable(
                          sortColumnIndex: 0,
                          sortAscending: true,
                          columns: <DataColumn>[
                            new DataColumn(label: Text('Disciplina', style: textStyle,),),
                            new DataColumn(label: Text('Aluno(a)', style: textStyle,)),
                            new DataColumn(label: Text('Orientador(a)', style: textStyle,)),
                            new DataColumn(label: Checkbox(value: value, onChanged: checksAll,)),
                          ],
                          rows: _createRows2(snapshot.data),
                      ),
                    ),
                ),
                 ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(18.0),),
                          color: Colors.blue,
                          child: Text("Validar",style: TextStyle(color: Colors.white)),
                          onPressed: (){
                            setState(() =>loading = true);
                            validarPedidos();
                            setState(() =>loading = false);
                            showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                            content: new Text(
                                                'Pedidos validados!'),
                                            actions: <Widget>[
                                              new FlatButton(
                                                textColor: Colors.white,
                                                color: Colors.blue[300],
                                                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(18.0),),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                                child: new Text('Ok'),
                                              ),
                                            ],
                                          ));
                          }
                        ),
                        RaisedButton(
                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(18.0),),
                          color: Colors.red,
                          child: Text("Recusar",style: TextStyle(color: Colors.white)),
                          onPressed: (){
                            setState(() =>loading = true);
                            recusarPedidos();
                            setState(() =>loading = false);
                            showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                            content: new Text(
                                                'Pedidos recusados!'),
                                            actions: <Widget>[
                                              new FlatButton(
                                                textColor: Colors.white,
                                                color: Colors.blue[300],
                                                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(18.0),),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                                child: new Text('Ok'),
                                              ),
                                            ],
                                          ));
                          }
                        ),
                      ],
                    ),
                  ),
               ],
             );
           }
         )
      );
  }
}