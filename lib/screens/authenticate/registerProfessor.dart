import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../models/user.dart';

class RegisterProfessor extends StatefulWidget {

  @override
  _RegisterProfessorState createState() => _RegisterProfessorState();
}

class _RegisterProfessorState extends State<RegisterProfessor> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String matricula = '';
  String nome = '';
  String password = '';
  String email = '';
  String telefone = '';
  String tipoUsuario='Professor';
  String areaAtuacao='';
  String error = '';
  var maskFormatter = new MaskTextInputFormatter(mask: '(##) #####-####', filter: { "#": RegExp(r'[0-9]') });
  var horarios = ["7:15 - 8:00", "8:00 - 8:45","9:00 - 9:45","9:45 - 10:30","10:45 - 11:30","11:30 - 12:15",
        "13:30 - 14:15", "14:15 - 15:00","15:15 - 16:00","16:00 - 16:45","17:00 - 17:45","17:45 - 18:30",
        "18:45 - 19:30", "19:30 - 20:15","20:30 - 21:15","21:15 - 22:00"];

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              elevation: 0.0,
              title: Text('Cadastro no App TCC')
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      TextFormField(
                        keyboardType: TextInputType.number,
                          decoration: textInputDecoration.copyWith(
                              hintText: 'Matrícula'),
                          validator: (val) =>
                              val.isEmpty ? 'Digite uma matrícula.' : null,
                          onChanged: (val) {
                            setState(() => matricula = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          decoration:
                              textInputDecoration.copyWith(hintText: 'Nome'),
                          validator: (val) =>
                              val.isEmpty ? 'Digite um nome.' : null,
                          onChanged: (val) {
                            setState(() => nome = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          decoration:
                              textInputDecoration.copyWith(hintText: 'Senha'),
                          validator: (val) => val.length < 6
                              ? 'Digite uma senha com mais de 6 caracteres.': null,
                          obscureText: true,
                          onChanged: (val) {
                            setState(() => password = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          decoration:
                              textInputDecoration.copyWith(hintText: 'Email'),
                          validator: (val) =>
                              val.isEmpty ? 'Digite um email.' : null,
                          onChanged: (val) {
                            setState(() => email = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [maskFormatter],
                          decoration: textInputDecoration.copyWith(
                              hintText: 'Telefone'),
                          validator: (val) =>
                              val.isEmpty || maskFormatter.getUnmaskedText().length != 11 ? 'Digite um telefone.' : null,
                          onChanged: (val) {
                            setState(() => telefone = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          decoration: textInputDecoration.copyWith(
                              hintText: 'Área de atuação'),
                          validator: (val) =>
                              val.isEmpty ? 'Digite uma área de atuação.' : null,
                          onChanged: (val) {
                            setState(() => areaAtuacao = val);
                          }),
                      SizedBox(height: 20.0),
                      RaisedButton(
                          color: Colors.blue,
                          child: Text(
                            "Confirmar",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              //setState(() => loading = true);
                              User us = new User(nome:nome, matricula:matricula, curso: "", email: email, telefone: telefone, tipoUsuario: tipoUsuario, areaAtuacao: areaAtuacao, senha: password);
                              Navigator.pushReplacementNamed(context, '/horarios', arguments: us);
                            }
                          }),
                      SizedBox(height: 12.0),
                      Text(error,
                          style: TextStyle(color: Colors.red, fontSize: 14.0))
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
