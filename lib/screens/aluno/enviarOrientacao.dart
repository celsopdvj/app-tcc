import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class EnviarOrientacao extends StatefulWidget {
  final User user;
  EnviarOrientacao({Key key, @required this.user}):super(key:key);
  @override
  _EnviarOrientacaoState createState() => _EnviarOrientacaoState();
}

class _EnviarOrientacaoState extends State<EnviarOrientacao> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _professorAtual = '';
  String nomeProfessor = '';
  String nomeAluno = '';
  bool _botaoEnviarDesabilitado ;
  


  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value),
        duration: Duration(seconds: 3),
    ));
  }

  void enviarPedido() async{
    if(_professorAtual != ''){
      _botaoEnviarDesabilitado = await DatabaseService(uid: widget.user.uid).getPedidoPendente(widget.user.uid);
      if(_botaoEnviarDesabilitado)
        mostrarModal();
      else{
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: new Text("Pedido enviado."),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          )
        );
        DatabaseService().updatePedidoPendente(widget.user.uid, _professorAtual, widget.user.nome, nomeProfessor);
        _professorAtual = '';
      }
    }
    else{
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: new Text("Escolha um professor."),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          )
        );
    }
  }

  void mostrarModal(){
    Widget botaoSim = RaisedButton(
            color: Colors.blue[300],
            child: Text("Sim",style: TextStyle(color: Colors.white),),
            onPressed: (){
              DatabaseService().deletaPedidoPendenteDoAluno(widget.user.uid);
              Navigator.of(context).pop();
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: new Text("Pedido cancelado.", style: TextStyle(color: Colors.white),),
                  duration: Duration(seconds: 3),
                  backgroundColor: Colors.green,
                  
                ));
            },
          );
    Widget botaoNao = RaisedButton(
            color: Colors.blue[300],
            child: Text("Não",style: TextStyle(color: Colors.white),),
            onPressed: (){
              Navigator.of(context).pop();
            },
          );
    AlertDialog alert = AlertDialog(
      content:  Text('Já possui um pedido pendente. Deseja cancela-lo?'),
      actions: <Widget>[
        botaoSim,
        botaoNao
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context){
        return alert;
      }
    );
  }



  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    ScrollController _controller = new ScrollController();

    return  Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Professores'),
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
      stream: Firestore.instance.collection('usuario').where('tipo' ,isEqualTo: "Professor").snapshots(),
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
                      groupValue: _professorAtual,
                      value: document.documentID,
                      title: new Text(document['nome']),
                      subtitle: new Text("Area de atuação: "+document['areaAtuacao']),
                      onChanged: (val){
                        setState((){ 
                          _professorAtual = val.toString();
                          nomeProfessor = document['nome'].toString();
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
                  child: Text("Enviar",style: TextStyle(color: Colors.white)),
                  onPressed: enviarPedido,
                ),
              ),
            ],
          );
        },
        ),
      );
    }
  }