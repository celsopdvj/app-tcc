import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:email_validator/email_validator.dart';

class EditarCadastroCoordenacao extends StatefulWidget {
  final User user;
  EditarCadastroCoordenacao({Key key, @required this.user}) : super(key: key);
  @override
  _EditarCadastroCoordenacaoState createState() =>
      _EditarCadastroCoordenacaoState();
}

class _EditarCadastroCoordenacaoState extends State<EditarCadastroCoordenacao> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  FirebaseUser firebaseUser;
  String matricula = '';

  String password = '';
  String email = '';
  String confirmPassword = '';

  String error = '';
  bool _obscurePassword = true;

  var maskFormatter = new MaskTextInputFormatter(
      mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  Future getUser() async {
    return await FirebaseAuth.instance.currentUser();
  }

  @override
  void initState() {
    super.initState();
    getUser().then((onValue) => firebaseUser = onValue);
    matricula = widget.user.matricula;
    email = widget.user.email;
    password = widget.user.senha;
  }

  Future<void> trocarEmail() async {
    if (this.email != widget.user.email) {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      await user.updateEmail(email).then((onValue) {
        var result = EmailAuthProvider.getCredential(
            email: email, password: widget.user.senha);
        user.reauthenticateWithCredential(result);
      });
      widget.user.email = email;
    }
  }

  Future<void> trocarPassword() async {
    if (this.password != widget.user.senha) {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      await user.updatePassword(password).then((onValue) {
        var result = EmailAuthProvider.getCredential(
            email: widget.user.email, password: password);
        user.reauthenticateWithCredential(result);
      });
      widget.user.senha = password;
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              elevation: 0.0,
              title: Text('Editar perfil'),
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
                          initialValue: matricula,
                          keyboardType: TextInputType.number,
                          decoration: textInputDecoration.copyWith(
                            labelText: "Matrícula",
                            hintText: 'Digite sua matrícula',
                          ),
                          validator: (val) =>
                              val.isEmpty ? 'Digite uma matrícula.' : null,
                          onChanged: (val) {
                            setState(() => matricula = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          initialValue: password,
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
                              labelText: "Senha",
                              hintText: 'Digite sua senha'),
                          validator: (val) => val.length < 6
                              ? 'Digite uma senha com mais de 6 caracteres.'
                              : null,
                          obscureText: _obscurePassword,
                          onChanged: (val) {
                            setState(() => password = val);
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          initialValue: password,
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
                          initialValue: email,
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
                              setState(() => loading = true);
                              if (await DatabaseService()
                                      .checarEmailCadastrado(email) &&
                                  email != widget.user.email) {
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
                                
                                print("ok");
                                try {
                                  await trocarEmail();
                                  await trocarPassword();
                                  DatabaseService().editarCadastroCoordenacao(
                                    widget.user.uid,
                                    matricula,
                                    email,
                                  );
                                  setState(() {
                                    loading = false;
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                            content:
                                                new Text('Dados alterados!'),
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
                                                  widget.user.matricula =
                                                      matricula;
                                                  widget.user.email = email;
                                                  Navigator.of(context)
                                                      .pushNamedAndRemoveUntil(
                                                          '/homeCoordenacao',
                                                          (Route<dynamic>
                                                                  route) =>
                                                              false,
                                                          arguments:
                                                              widget.user);
                                                },
                                                child: new Text('Ok'),
                                              ),
                                            ],
                                          ));
                                } catch (e) {
                                  showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                            content: new Text(
                                                'Houve um erro ao alterar os dados.'),
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
