import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConvitesDefesa extends StatefulWidget {
  final User user;
  ConvitesDefesa({Key key, @required this.user}):super(key:key);
  @override
  _ConvitesDefesaState createState() => _ConvitesDefesaState();
}

class _ConvitesDefesaState extends State<ConvitesDefesa> {
  bool loading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String defesaEscolhida = "";
  DatabaseService banco = new DatabaseService();

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    ScrollController _controller = new ScrollController(keepScrollOffset: true);
    
    return loading ? Loading() : Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Convites de defesa'),
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
      stream: Firestore.instance.collection('usuario').document(widget.user.uid).collection("Convites").snapshots(),
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
                      isThreeLine: true,
                      groupValue: defesaEscolhida,
                      value: document.documentID,
                      title: Text("Aluno(a): "+document.data['aluno']),
                      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start,children: <Widget>[Text("Orientador(a): "+document.data['orientador']),
                       Text("Defesa: "+document.data['data'] + " - " + document.data['horario'])],),
                      onChanged: (val){
                        setState(() {
                          defesaEscolhida = document.documentID;
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
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(18.0),),
                      color: Colors.blue,
                      child: Text("Aceitar",style: TextStyle(color: Colors.white)),
                      onPressed: (){
                        setState(() =>loading = true);
                        if(defesaEscolhida==""){
                          setState(() =>loading = false);
                          showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                            content: new Text(
                                                'Escolha um convite!'),
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
                        else{
                          banco.aceitarPedidoDefesa(widget.user.uid, defesaEscolhida);
                          setState(() =>loading = false);
                          showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                            content: new Text(
                                                'Convite aceito!'),
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
                        
                      }
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(18.0),),
                      color: Colors.red,
                      child: Text("Recusar",style: TextStyle(color: Colors.white)),
                      onPressed: (){
                        setState(() =>loading = true);
                        if(defesaEscolhida==""){
                          setState(() =>loading = false);
                          showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                            content: new Text(
                                                'Escolha um convite!'),
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
                        else{
                          banco.recusarPedidoDefesa(widget.user.uid, defesaEscolhida);
                          setState(() =>loading = false);
                          showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                            content: new Text(
                                                'Convite recusado!'),
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