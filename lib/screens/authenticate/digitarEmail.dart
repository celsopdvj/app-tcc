import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:flutter/material.dart';

class DigitarEmail extends StatefulWidget {
  @override
  _DigitarEmailState createState() => _DigitarEmailState();
}

class _DigitarEmailState extends State<DigitarEmail> {
  final _formKey = GlobalKey<FormState>();
  final _auth = new AuthService();
  String email = '';
  String error = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 0.0,
          title: Text('Recuperar senha')),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
                          child: TextFormField(
                  decoration:
                      textInputDecoration.copyWith(hintText: 'Digite seu e-mail'),
                  validator: (val) => val.isEmpty ? 'Digite seu e-mail.' : null,
                  onChanged: (val) {
                    setState(() {
                      email = val;
                    });
                  }),
            ),
            RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(18.0),),
                color: Colors.blue[300],
                child: Text(
                  "Confirmar",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {            
                    int result =  await _auth.resetarSenha(email);
                    if(result != 1){
                      setState(() {
                        error = '';
                      });
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: new Text("Um email foi enviado para resetar sua senha."),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.green,
                      ));
                    }
                    else{
                      setState(() {
                        error = 'E-mail inválido';
                      });
                    }
                  }
                }),
            SizedBox(height: 12.0),
                      Text(error,
                          style: TextStyle(color: Colors.red, fontSize: 14.0))
          ],
        ),
      ),
    );
  }
}
