import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EnviarOrientacao extends StatefulWidget {
  final User user;
  EnviarOrientacao({Key key, @required this.user}) : super(key: key);
  @override
  _EnviarOrientacaoState createState() => _EnviarOrientacaoState();
}

class _EnviarOrientacaoState extends State<EnviarOrientacao> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _professorAtual = '';
  String nomeProfessor = '';
  String nomeAluno = '';
  bool _botaoEnviarDesabilitado;
  String disciplina = '';
  List<String> tccFisica = ['MAF1318', 'MAF1319'];
  List<String> tccCmp = ['CMP1071', 'CMP1072'];
  String tccMat = 'MAF1149';
  List<DropdownMenuItem> disciplinas;
  String erro = '';

  @override
  void initState() {
    super.initState();
    if (widget.user.curso == "Engenharia de Computação" ||
        widget.user.curso == "Ciência da Computação") {
      disciplinas = mostrarTccCmp();
    } else if (widget.user.curso == "Matemática") {
      disciplina = tccMat;
    } else
      disciplinas = mostrarTccFisica();
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      duration: Duration(seconds: 3),
    ));
  }

  List<DropdownMenuItem> mostrarTccFisica() {
    return tccFisica.map((String disciplina) {
      return DropdownMenuItem<String>(
        value: disciplina,
        child: Text(disciplina),
      );
    }).toList();
  }

  List<DropdownMenuItem> mostrarTccCmp() {
    return tccCmp.map((String disciplina) {
      return DropdownMenuItem<String>(
        value: disciplina,
        child: Text(disciplina),
      );
    }).toList();
  }

  List<DropdownMenuItem> mostrarTccMat() {
    List<DropdownMenuItem> list = new List<DropdownMenuItem>();
    list.add(DropdownMenuItem<String>(
      value: tccMat,
      child: Text(tccMat),
    ));
    return list;
  }

  void enviarPedido() async {
    if (_professorAtual != '') {
      _botaoEnviarDesabilitado = await DatabaseService(uid: widget.user.uid).getPedidoPendente(widget.user.uid);
      if(_botaoEnviarDesabilitado)
          mostrarModal();
      else if(widget.user.curso != "Matemática")
       mostrarModalDisciplina();
      else{

          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: new Text("Pedido enviado."),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            )
          );
          DatabaseService().updatePedidoPendente(widget.user.uid, _professorAtual, widget.user.nome, nomeProfessor, "MAF1149");
          _professorAtual = '';
      }
      
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: new Text("Escolha um professor."),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ));
    }
  }

  void mostrarModalDisciplina() {
    Widget botaoConfirmar = RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(18.0),),
      color: Colors.blue[300],
      child: Text(
        "Confirmar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        if(disciplina == ''){
          setState(() {
            erro = "Selecione uma disciplina";
          });
        }
        else{
          _botaoEnviarDesabilitado = await DatabaseService(uid: widget.user.uid)
              .getPedidoPendente(widget.user.uid);
          if (_botaoEnviarDesabilitado)
            mostrarModal();
          else {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: new Text("Pedido enviado."),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            ));
            DatabaseService().updatePedidoPendente(
                widget.user.uid,
                _professorAtual,
                widget.user.nome,
                nomeProfessor,
                disciplina);
          }
          Navigator.of(context).pop();
        }
      },
    );
    Widget botaoCancelar = RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(18.0),),
      color: Colors.white,
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text('Selecione uma disciplina'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text("Disciplina: "),
              StatefulBuilder(
                builder:(BuildContext context, StateSetter setState) {
                  return DropdownButton(
                    hint: Text(disciplina),
                    items: disciplinas,
                    onChanged: (val) {
                      print(val);
                      setState(() {
                        disciplina = val;
                      });
                    });
               }
              ),
            ],
          ),
          Text(erro, style: TextStyle(color: Colors.red))
        ],
      ),
      actions: <Widget>[ botaoCancelar,botaoConfirmar,],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void mostrarModal() {
    Widget botaoSim = RaisedButton(
      textColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(18.0),),
      color: Colors.blue[300],
      child: Text(
        "Sim",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        await DatabaseService().deletaPedidoPendenteDoAluno(widget.user.uid);
        Navigator.of(context).pop();
        mostrarModalDisciplina();
      },
    );
    Widget botaoNao = RaisedButton(
      textColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(18.0),),
      color: Colors.white,
      child: Text(
        "Não",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      content: Text(
          'Já possui um pedido pendente. Deseja cancela-lo e enviar um novo convite para este professor?'),
      actions: <Widget>[botaoSim, botaoNao],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    ScrollController _controller = new ScrollController(keepScrollOffset: true);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Professores'),
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
        stream: Firestore.instance
            .collection('usuario')
            .where('tipo', isEqualTo: "Professor")
            .snapshots(),
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
                      subtitle: new Text(
                          "Area de atuação: " + document['areaAtuacao']),
                      onChanged: (val) {
                        setState(() {
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
                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(18.0),),
                  color: Colors.blue,
                  child: Text("Enviar", style: TextStyle(color: Colors.white)),
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
