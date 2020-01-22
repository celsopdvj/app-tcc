import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:flutter/material.dart';

class FormularioOrientacao extends StatefulWidget {
  final User user;
  final User aluno;
  FormularioOrientacao({Key key, @required this.user, @required this.aluno}):super(key:key);
  @override
  _FormularioOrientacaoState createState() => _FormularioOrientacaoState();
}

class _FormularioOrientacaoState extends State<FormularioOrientacao> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  var diasDaSemana = ['Segunda','Terça','Quarta','Quinta','Sexta'];
  List<int> horas = new List<int>.generate(25, (i) => i);
  List<int> minutos = new List<int>.generate(61, (i) => i);

  String curso = ''; // pegar do aluno
  String disciplina = 'CMP1071'; // pegar do banco
  String turma = '';  // pegar do banco
  String diaDaSemana = 'Selecione...'; 
  TimeOfDay horario;

  String professor = ''; // pegar do usuario
  String matriculaAluno = ''; // pegar do aluno
  String nomeAluno = ''; // pegar do aluno
  String observacoes = '';
  String error = '';

  Future<Null> _selectedTime(BuildContext context) async {
    horario = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now());
    if (horario != null) {
      setState(() {
        horario = horario;
      });
      print(horario);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              elevation: 0.0,
              title: Text('Formulário de orientação'),
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      Row(
                        children: <Widget>[
                          Text("Dia da semana:   "),
                          DropdownButton(
                            hint: Text(diaDaSemana),
                            items: diasDaSemana.map((String diaEscolhido){
                              return DropdownMenuItem<String>(
                                value: diaEscolhido,
                                child: Text(diaEscolhido),
                              );
                            }).toList(),
                            onChanged: (val){
                              print(val);
                              setState(() {
                                diaDaSemana = val;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        children: <Widget>[
                          Text("Horário:   "),
                          FlatButton(
                              child: horario == null ? Text("Selecione")
                                                      :Text(horario.format(context)),
                              onPressed: () => _selectedTime(context)
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        maxLines: 4,
                        decoration: textInputDecoration.copyWith(hintText: 'Observações...'),
                        onChanged: (val) {
                          setState(() => observacoes = val);
                        }),
                      SizedBox(height: 20.0),
                      RaisedButton(
                          color: Colors.blue,
                          child: Text(
                            "Confirmar",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              
                              print(professor = widget.user.nome);
                              print(curso = widget.user.curso);
                              print(matriculaAluno = widget.aluno.matricula);
                              print(nomeAluno = widget.aluno.nome);

                              //pegar contador do banco e montar turma
                              
                              //metodo do database para salvar orientação

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