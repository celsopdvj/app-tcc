import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ValidarOrientacao extends StatefulWidget {
  final User user;
  ValidarOrientacao({Key key, @required this.user}):super(key:key);
  @override
  _ValidarOrientacaoState createState() => _ValidarOrientacaoState();
}

class _ValidarOrientacaoState extends State<ValidarOrientacao> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DatabaseService banco = new DatabaseService();
  Map<String, bool> listaPedidosMarcados = new Map<String,bool>();
  bool loading = false;


  void validarPedidos(){
    print(listaPedidosMarcados);
    listaPedidosMarcados.forEach((k,v){
      if(v){
        banco.validaPedidoPendente(k);
      }
    });
    listaPedidosMarcados.clear();
  }

  void recusarPedidos(){
    print(listaPedidosMarcados);
    listaPedidosMarcados.forEach((k,v){
      if(v){
        banco.deletarPedido(k);
      }
    });
    listaPedidosMarcados.clear();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    ScrollController _controller = new ScrollController();
    
    return loading ? Loading() : Scaffold(
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
      stream: Firestore.instance.collection('pedidoPendente').where('validado' ,isEqualTo: false).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Loading();
        return Column(
          children: <Widget>[
            Expanded(
                child: new ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _controller,
                  children: snapshot.data.documents.map((document) {
                    return new CheckboxListTile(
                      key: Key(document.documentID),
                      value: listaPedidosMarcados[document.documentID] == null ? false : listaPedidosMarcados[document.documentID],
                      title: Text(document['disciplina'] + " - " + document['nomeAluno']),
                      subtitle: Text("Orientador: "+ document['nomeProfessor']),
                      onChanged: (val){
                        setState(() {
                          listaPedidosMarcados[document.documentID] = val;
                        });
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
                    RaisedButton(
                      color: Colors.blue,
                      child: Text("Validar",style: TextStyle(color: Colors.white)),
                      onPressed: (){
                        setState(() =>loading = true);
                        validarPedidos();
                        setState(() =>loading = false);
                      }
                    ),
                    RaisedButton(
                      color: Colors.red,
                      child: Text("Recusar",style: TextStyle(color: Colors.white)),
                      onPressed: (){
                        setState(() =>loading = true);
                        recusarPedidos();
                        setState(() =>loading = false);
                      }
                    ),
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