import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

final AuthService _auth = AuthService();
final _formKey = GlobalKey<FormState>();
bool loading = false;

String matricula = '';
String password = '';
String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/puc.png'),
              SizedBox(height: 20.0),
              TextFormField(
                keyboardType: TextInputType.numberWithOptions(),
                decoration: textInputDecoration.copyWith(
                  enabledBorder: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide()
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                  ),
                  hintText: 'Matrícula'),
                validator: (val) => val.isEmpty ? 'Digite uma matrícula.' : null,
                onChanged: (val){
                  setState(() => matricula=val);
                }
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: textInputDecoration.copyWith(
                  enabledBorder: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide()
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                  ),
                  hintText: 'Senha'),
                validator: (val) => val.length <6 ? 'Digite uma senha com mais de 6 caracteres.' : null,
                obscureText: true,
                onChanged: (val){
                  setState(() => password=val);
                }
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.blue[300],
                    child: Text(
                      "Entrar",
                      style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async{
                        if(_formKey.currentState.validate()){
                          setState(()=>loading=true);
                          final doc = await Firestore.instance.collection('usuario').where("matricula", isEqualTo: matricula).getDocuments();
                          dynamic result = await _auth.logInComMatriculaESenha(doc.documents.first.documentID, password);
                          if(result == null){
                            setState(() {
                               error = 'Usuário ou senha inválido.';
                               loading = false;
                            });
                          }
                          else{
                            if(doc.documents.first.data["tipo"] == "Aluno"){
                            Navigator.pushReplacementNamed(context, '/home', arguments: result);
                          }
                          else if(doc.documents.first.data['tipo'] == "Professor"){
                            Navigator.pushReplacementNamed(context, '/homeProfessor',arguments: result);
                          }
                          else
                            Navigator.pushReplacementNamed(context, '/homeCoordenacao',arguments: result);
                          }
                        }
                      }
                  ),
                  RaisedButton(
                    color: Colors.blue[300],
                    child: Text(
                      "Cadastre-se",
                      style: TextStyle(color: Colors.white),
                      ),
                    onPressed: (){
                      Navigator.pushNamed(context, '/tipoUsuario');
                    },
                  )
                ],
              ),
              SizedBox(height: 20.0),
              OutlineButton(
                child: Text('Recuperar senha', style: TextStyle(fontSize: 14, color: Colors.black)),
                onPressed: (){
                  Navigator.pushNamed(context, '/resetarSenha');
                },
              )
              ,
              SizedBox(height: 12.0),
                      Text(error,
                          style: TextStyle(color: Colors.red, fontSize: 14.0))
            ],
          ),
        ),
      ),
    );
  }
}
