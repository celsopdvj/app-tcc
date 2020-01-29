import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:flutter/material.dart';

class FormularioOrientacao extends StatefulWidget {
  final User user;
  final User aluno;
  final String pedidoUid;
  FormularioOrientacao({Key key, @required this.user, @required this.aluno, @required this.pedidoUid}):super(key:key);
  @override
  _FormularioOrientacaoState createState() => _FormularioOrientacaoState();
}

class _FormularioOrientacaoState extends State<FormularioOrientacao> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  DatabaseService banco = new DatabaseService();
  var diasDaSemana = ['Segunda','Terça','Quarta','Quinta','Sexta'];
  //List<int> horas = new List<int>.generate(25, (i) => i);
  //List<int> minutos = new List<int>.generate(61, (i) => i);

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
                          Text("Dia da semana:   ", style: TextStyle(fontSize: 16)),
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
                          Text("Horário:   ", style: TextStyle(fontSize: 16),),
                          FlatButton(
                              child: horario == null ? Text("Selecione...", style: TextStyle(fontSize: 16, color: Colors.black38))
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
                          onPressed: () async{
                            if (_formKey.currentState.validate()) {
                              setState(()=>loading=true);
                              curso = widget.aluno.curso;
                              professor = widget.user.nome;
                              matriculaAluno = widget.aluno.matricula;
                              nomeAluno = widget.aluno.nome;

                              //pegar contador do banco e montar turma
                              int aux = await banco.getTurma();
                              print(aux);
                              turma = "A" + aux.toString().padLeft(2,'0');
                              print(turma);

                              //metodo do database para salvar orientação
                              //passar uid do pedido para remove-lo (excluido = 1)
                              try{
                                banco.salvarOrientacao(curso, disciplina, turma, diaDaSemana, horario.format(context).toString()
                                                      , professor, matriculaAluno, nomeAluno, observacoes, widget.aluno.uid, widget.user.uid);
                                banco.deletarPedido(widget.pedidoUid);
                                Navigator.of(context).pop();
                              }
                              catch(e){
                                setState(() {
                                  error = 'Erro ao salvar orientação!';
                                  print(e);
                                  loading = false;
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
              ),
            ),
          );
  }
}