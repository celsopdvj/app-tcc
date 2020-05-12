import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:email_validator/email_validator.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String matricula = '';
  String nome = '';
  String password = '';
  String curso = 'Selecione...';
  String email = '';
  String telefone = '';
  String tipoUsuario = 'Aluno';
  String error = '';
  var maskFormatter = new MaskTextInputFormatter(
      mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  var cursos = [
    'Análise e Desenvolvimento de Sistemas',
    'Ciência da Computação',
    'Engenharia de Computação',
    'Física',
    'Matemática',
    'Química'
  ];

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              elevation: 0.0,
              title: Text('Cadastro no App TCC'),
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
                            labelText: "Matrícula",
                            hintText: 'Digite sua matrícula',
                          ),
                          validator: (val) => val.isEmpty || val.length != 14
                              ? 'Digite uma matrícula com 14 dígitos.'
                              : null,
                          onChanged: (val) {
                            setState(() => matricula = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          decoration:
                              textInputDecoration.copyWith(
                                labelText: "Nome",
                                hintText: 'Digite seu nome completo'),
                          validator: (val) =>
                              val.isEmpty ? 'Digite um nome.' : null,
                          onChanged: (val) {
                            setState(() => nome = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          decoration:
                              textInputDecoration.copyWith(
                                labelText: "Senha",
                                hintText: 'Digite sua senha'),
                          validator: (val) => val.length < 6
                              ? 'Digite uma senha com mais de 6 caracteres.'
                              : null,
                          obscureText: true,
                          onChanged: (val) {
                            setState(() => password = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          decoration:
                              textInputDecoration.copyWith(labelText: 'Email',
                              hintText: "Digite seu email"),
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
                      Column(
                        children: <Widget>[
                          Text("Curso:   ", style: TextStyle(fontSize: 16)),
                          DropdownButton(
                            hint: Text(curso, style: TextStyle(fontSize: 14)),
                            items: cursos.map((String diaEscolhido) {
                              return DropdownMenuItem<String>(
                                value: diaEscolhido,
                                child: Text(
                                  diaEscolhido,
                                  style: TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              print(val);
                              setState(() {
                                curso = val;
                              });
                            },
                          ),
                        ],
                      ),
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
                            if (curso == "Selecione...") {
                              setState(() {
                                error = 'Selecione um curso.';
                                loading = false;
                              });
                            } else {
                              if (_formKey.currentState.validate()) {
                                setState(() => loading = true);
                                if (await DatabaseService()
                                    .checarEmailCadastrado(email)) {
                                  setState(() => loading = false);
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
                                } else {
                                  dynamic result =
                                      await _auth.registroDeUsuario(
                                          matricula,
                                          password,
                                          nome,
                                          curso,
                                          email,
                                          telefone,
                                          tipoUsuario,
                                          "",
                                          false);
                                  if (result == null) {
                                    setState(() {
                                      error = 'Erro ao registrar';
                                      loading = false;
                                    });
                                  } else if (result == 1) {
                                    setState(() {
                                      error = 'Matricula já cadastrada';
                                      loading = false;
                                    });
                                  } else
                                    Navigator.pushReplacementNamed(
                                        context, '/home',
                                        arguments: result);
                                }
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
