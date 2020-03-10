import 'dart:io';

import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class FormularioDeEnvioTCC extends StatefulWidget {
  final User user;
  final User aluno;
  FormularioDeEnvioTCC({Key key, @required this.user,@required this.aluno}):super(key:key);
  @override
  FormularioDeEnvioTCCState createState() => FormularioDeEnvioTCCState();
}

class FormularioDeEnvioTCCState extends State<FormularioDeEnvioTCC> {
  String fileType = '';
  File file;
  String fileName = '';
  String operationText = '';
  bool isUploaded = true;
  String result = '';
  bool loading = false;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DatabaseService banco = new DatabaseService();
  String error = '';
  String nomeAluno = '';
  String titulo = '';
  String area = '';

  @override
  Widget build(BuildContext context) {
    


    Future<void> _uploadFile(File file, String filename) async {
      StorageReference storageReference;
      storageReference = FirebaseStorage.instance.ref().child("$filename");
      final StorageUploadTask uploadTask = storageReference.putFile(file);
      final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
      final String url = (await downloadUrl.ref.getDownloadURL());
      print("URL is $url");
      banco.salvarTCC(nomeAluno, titulo, area, url, filename);
    }
    void enviarTCC() async{
      Future filePicker(BuildContext context) async {
        try {
          file =
              await FilePicker.getFile(type: FileType.CUSTOM, fileExtension: 'pdf');
          fileName = p.basename(file.path);
          setState(() {
            fileName = p.basename(file.path);
          });
          print(fileName);
          _uploadFile(file, fileName);
          showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('TCC enviado.'),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                              });
        } catch (e) {
          setState(() {
            loading = false;
          });
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Erro ao enviar TCC.'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        }
      }
      await filePicker(context);
    }

    return  loading ? Loading():Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Enviar TCC'),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('Sair'),
            onPressed: () async {
              print(widget.user.uid);
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: 'Título do TCC',
                          enabledBorder: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            borderSide: new BorderSide()),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            ),
                        ),
                        validator: (val) =>
                              val.isEmpty ? 'Digite o título.' : null,
                        onChanged: (val) {
                          setState(() => titulo = val);
                        }),
                      SizedBox(height: 20.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: 'Área',
                          enabledBorder: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            borderSide: new BorderSide()),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            ),
                        ),
                        validator: (val) =>
                              val.isEmpty ? 'Digite a área do TCC.' : null,
                        onChanged: (val) {
                          setState(() => area = val);
                        }),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: RaisedButton(
                          color: Colors.blue,
                          child: Text("Enviar", style: TextStyle(color: Colors.white)),
                          onPressed: () async{
                            if (_formKey.currentState.validate()) {
                              nomeAluno = widget.aluno.nome;
                              setState(() {
                                loading = true;
                              });
                              await enviarTCC();
                              setState(() {
                                loading = false;
                              });
                            }
                          }
                        ),
                      ),
                      Text(error,
                          style: TextStyle(color: Colors.red, fontSize: 14.0))
                    ],
                  ),
                ),
              ),
      );
  }
}