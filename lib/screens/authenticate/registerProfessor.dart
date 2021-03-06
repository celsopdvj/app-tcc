import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../models/user.dart';
import 'package:email_validator/email_validator.dart';

class RegisterProfessor extends StatefulWidget {
  @override
  _RegisterProfessorState createState() => _RegisterProfessorState();
}

class _RegisterProfessorState extends State<RegisterProfessor> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String matricula = '';
  String nome = '';
  String password = '';
  String confirmPassword = '';
  String email = '';
  String telefone = '';
  String tipoUsuario = 'Professor';
  String areaAtuacao = '';
  bool _obscurePassword = true;
  String error = '';
  var maskFormatter = new MaskTextInputFormatter(
      mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  var horarios = [
    "7:15 - 8:00",
    "8:00 - 8:45",
    "9:00 - 9:45",
    "9:45 - 10:30",
    "10:45 - 11:30",
    "11:30 - 12:15",
    "13:30 - 14:15",
    "14:15 - 15:00",
    "15:15 - 16:00",
    "16:00 - 16:45",
    "17:00 - 17:45",
    "17:45 - 18:30",
    "18:45 - 19:30",
    "19:30 - 20:15",
    "20:30 - 21:15",
    "21:15 - 22:00"
  ];

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.blue,
                elevation: 0.0,
                title: Text('Cadastre-se')),
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
                              labelText: 'Matrícula',
                              hintText: "Digite sua matrícula"),
                          validator: (val) =>
                              val.isEmpty || val.length > 7 ? 'Digite uma matrícula com até 7 digitos.' : null,
                          onChanged: (val) {
                            setState(() => matricula = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          decoration: textInputDecoration.copyWith(
                              labelText: 'Nome',
                              hintText: "Digite seu nome completo"),
                          validator: (val) =>
                              val.isEmpty ? 'Digite um nome.' : null,
                          onChanged: (val) {
                            setState(() => nome = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          decoration: textInputDecoration.copyWith(
                              suffixIcon: IconButton(
                                onPressed: () => setState(() {
                                  _obscurePassword = !_obscurePassword;
                                }),
                                icon: Icon(
                                  // Based on passwordVisible state choose the icon
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              labelText: 'Senha',
                              hintText: "Digite sua senha"),
                          validator: (val) => val.length < 6
                              ? 'Digite uma senha com mais de 6 caracteres.'
                              : null,
                          obscureText: _obscurePassword,
                          onChanged: (val) {
                            setState(() => password = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          decoration: textInputDecoration.copyWith(
                              suffixIcon: IconButton(
                                onPressed: () => setState(() {
                                  _obscurePassword = !_obscurePassword;
                                }),
                                icon: Icon(
                                  // Based on passwordVisible state choose the icon
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              labelText: "Confirmar senha",
                              hintText: 'Digite sua senha novamente'),
                          validator: (val) => val != password
                              ? 'Senhas não estão iguais.'
                              : null,
                          obscureText: _obscurePassword,
                          onChanged: (val) {
                            setState(() => confirmPassword = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          decoration: textInputDecoration.copyWith(
                              labelText: 'Email', hintText: "Digite seu email"),
                          validator: (val) =>
                              val.isEmpty || !EmailValidator.validate(val)
                                  ? 'Digite um email válido.'
                                  : null,
                          onChanged: (val) {
                            setState(() => email = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [maskFormatter],
                          decoration: textInputDecoration.copyWith(
                              labelText: 'Telefone',
                              hintText: "Digite seu telefone"),
                          validator: (val) => val.isEmpty ||
                                  maskFormatter.getUnmaskedText().length != 11
                              ? 'Digite um telefone válido.'
                              : null,
                          onChanged: (val) {
                            setState(() => telefone = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          decoration: textInputDecoration.copyWith(
                              labelText: 'Área de atuação',
                              hintText: "Digite sua área de atuação"),
                          validator: (val) => val.isEmpty
                              ? 'Digite uma área de atuação.'
                              : null,
                          onChanged: (val) {
                            setState(() => areaAtuacao = val);
                          }),
                      SizedBox(height: 20.0),
                      RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                          ),
                          color: Colors.blue,
                          child: Text(
                            "Confirmar",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              //sleep(const Duration(seconds: 2));
                              if (await DatabaseService()
                                  .checarEmailCadastrado(email)) {
                                showDialog(
                                    context: context,
                                    builder: (context) => new AlertDialog(
                                          content: new Text(
                                              'Já existe uma conta com este email.'),
                                          actions: <Widget>[
                                            new FlatButton(
                                              textColor: Colors.white,
                                              color: Colors.blue[300],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        18.0),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                              child: new Text('Ok'),
                                            ),
                                          ],
                                        ));
                              } else if (await DatabaseService()
                                  .checarMatriculaCadastrada(matricula)) {
                                showDialog(
                                    context: context,
                                    builder: (context) => new AlertDialog(
                                          content: new Text(
                                              'Matricula já cadastrada.'),
                                          actions: <Widget>[
                                            new FlatButton(
                                              textColor: Colors.white,
                                              color: Colors.blue[300],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        18.0),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                              child: new Text('Ok'),
                                            ),
                                          ],
                                        ));
                              } else {
                                User us = new User(
                                    nome: nome,
                                    matricula: matricula,
                                    curso: "",
                                    email: email,
                                    telefone: telefone,
                                    tipoUsuario: tipoUsuario,
                                    areaAtuacao: areaAtuacao,
                                    senha: password);
                                Navigator.pushNamed(context, '/horarios',
                                    arguments: us);
                              }
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
