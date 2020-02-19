import 'dart:io';
import 'package:app_tcc/models/defesas.dart';
import 'package:app_tcc/models/orientacoes.dart';
import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mailer2/mailer.dart';
import 'package:path_provider/path_provider.dart';

class HomeCoordenacao extends StatefulWidget {
  final User user;
  HomeCoordenacao({Key key, @required this.user}):super(key:key);
  @override
  _HomeCoordenacaoState createState() => _HomeCoordenacaoState();
}

class _HomeCoordenacaoState extends State<HomeCoordenacao> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    return loading ? Loading() : Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('PUC GO TCC - Coordenação'),
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
      //Botões com funcionalidades da coordenação
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ButtonTheme(
                minWidth: 300.0,
                height: 50.0,
                child: RaisedButton(
                color: Colors.blue[300],
                child: Text(
                  "Validar convite de orientação",
                  style: textStyle.copyWith(),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/validarPedidoOrientacao', arguments: widget.user);
                },
              ),
            ),
            SizedBox(height: 20.0),
            ButtonTheme(
                minWidth: 300.0,
                height: 50.0,
                child: RaisedButton(
                color: Colors.blue[300],
                child: Text(
                  "Exibir orientações",
                  style: textStyle.copyWith(),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/exibirOrientacoes');
                },
              ),
            ),
            SizedBox(height: 20.0),
            ButtonTheme(
                minWidth: 300.0,
                height: 50.0,
                child: RaisedButton(
                color: Colors.blue[300],
                child: Text(
                  "Gerar planilha de orientações",
                  style: textStyle.copyWith(),
                ),
                onPressed: () async {
                  setState(()  => loading = true);
                  await getCsvOrientacao(widget.user.email, _scaffoldKey);
                  setState(()  => loading = false);
                },
              ),
            ),
            SizedBox(height: 20.0),
            ButtonTheme(
                minWidth: 300.0,
                height: 50.0,
                child: RaisedButton(
                color: Colors.blue[300],
                child: Text(
                  "Exibir Defesas",
                  style: textStyle.copyWith(),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/exibirDefesas');
                },
              ),
            ),
            SizedBox(height: 20.0),
            ButtonTheme(
                minWidth: 300.0,
                height: 50.0,
                child: RaisedButton(
                color: Colors.blue[300],
                child: Text(
                  "Gerar planilha de defesas",
                  style: textStyle.copyWith(),
                ),
                onPressed: () async {
                  setState(()  => loading = true);
                  await getCsvDefesas(widget.user.email, _scaffoldKey);
                  setState(()  => loading = false);
                },
              ),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}

//Envio do email com planilha
getCsvOrientacao(String email, GlobalKey<ScaffoldState> _scaffoldKey) async{
  DatabaseService banco = new DatabaseService();
  List<Orientacao> lista = new List<Orientacao>();
  List<DocumentSnapshot> result = await banco.getOrientacoes();

  for (DocumentSnapshot doc in result) {
      Orientacao orientacao = new Orientacao(curso: doc.data['curso'], disciplina: doc.data['disciplina'], turma: doc.data['turma'],
                              matriculaAluno: doc.data['matricula'], observacoes: doc.data['observacoes'], nomeAluno: doc.data['nomeAluno'],
                              nomeProfessor: doc.data['nomeProfessor'], dia: doc.data['dia'], horario: doc.data['horario']);
      lista.add(orientacao);
  }
  String dir = (await getExternalStorageDirectory()).absolute.path + "/planilha_de_orientacoes_";
  String file = "$dir";

  File myFile = new File(file +"${DateTime.now()}.csv");

  List primeiraLinha = ['Curso','Disciplina','Turma','Dia','Horário','Professor','Matrícula Aluno','Aluno','Observações'];
  List<List> rows =new List<List>();
  rows.add(primeiraLinha);
  for (Orientacao ori in lista) {
    List row = new List();
    row.add(ori.curso);
    row.add(ori.disciplina);
    row.add(ori.turma);
    row.add(ori.dia);
    row.add(ori.horario);
    row.add(ori.nomeProfessor);
    row.add(ori.matriculaAluno);
    row.add(ori.nomeAluno);
    row.add(ori.observacoes);
    rows.add(row);
  }
 
  
  String csv = const ListToCsvConverter().convert(rows);
  myFile.writeAsString(csv);

  var options = new GmailSmtpOptions()
    ..username = 'puc.go.apptcc@gmail.com'
    ..password = 'pucgo123';

  var emailTransport = new SmtpTransport(options);

  var envelope = new Envelope()
    ..from = 'puc.go.apptcc@gmail.com'
    ..recipients.add('gjorgec@gmail.com')
    ..subject = 'Planilha de Orientações'
    ..attachments.add(new Attachment(file: myFile))
    ..text = 'Planilha de Orientações no anexo';


  emailTransport.send(envelope)
    .then((envelope) { 
      print('Email sent!');
      _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: new Text("Planilha foi enviada!"),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.green,
                      )
      );
    })
    .catchError((e){ 
      print('Error occurred: $e');
      _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: new Text("Ocorreu um erro e a planilha não foi enviada."),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.red,
                      )
      );
    });
}

getCsvDefesas(String email, GlobalKey<ScaffoldState> _scaffoldKey) async{
  DatabaseService banco = new DatabaseService();
  List<Defesa> lista = new List<Defesa>();
  List<DocumentSnapshot> result = await banco.getDefesas();

  for (DocumentSnapshot doc in result) {
      Defesa defesa = new Defesa(data: doc.data['data'], horario: doc.data['horario'], local: doc.data['sala'],
                              disciplina: doc.data['disciplina'], nomeAluno: doc.data['nomeAluno'], titulo: doc.data['titulo'],
                              orientador: doc.data['orientador']);
      lista.add(defesa);
  }
  String dir = (await getExternalStorageDirectory()).absolute.path + "/planilha_de_defesas_";
  String file = "$dir";

  File myFile = new File(file +"${DateTime.now()}.csv");

  List primeiraLinha = ['Data','Horário','Local','Disciplina','Aluno','Título','Orientador'];
  List<List> rows =new List<List>();
  rows.add(primeiraLinha);
  for (Defesa def in lista) {
    List row = new List();
    row.add(def.data);
    row.add(def.horario);
    row.add(def.local);
    row.add(def.disciplina);
    row.add(def.nomeAluno);
    row.add(def.titulo);
    row.add(def.orientador);
    rows.add(row);
  }
 
  
  String csv = const ListToCsvConverter().convert(rows);
  myFile.writeAsString(csv);

  var options = new GmailSmtpOptions()
    ..username = 'puc.go.apptcc@gmail.com'
    ..password = 'pucgo123';

  var emailTransport = new SmtpTransport(options);

  var envelope = new Envelope()
    ..from = 'puc.go.apptcc@gmail.com'
    ..recipients.add('gjorgec@gmail.com')
    ..subject = 'Planilha de Defesas'
    ..attachments.add(new Attachment(file: myFile))
    ..text = 'Planilha de Defesas no anexo';


  emailTransport.send(envelope)
    .then((envelope) { 
      print('Email sent!');
      _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: new Text("Planilha foi enviada!"),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.green,
                      )
      );
    })
    .catchError((e){ 
      print('Error occurred: $e');
      _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: new Text("Ocorreu um erro e a planilha não foi enviada."),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.red,
                      )
      );
    });
}