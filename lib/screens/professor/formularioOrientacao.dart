import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:flutter/material.dart';

class FormularioOrientacao extends StatefulWidget {
  final User user;
  final User aluno;
  final String pedidoUid;
  FormularioOrientacao(
      {Key key,
      @required this.user,
      @required this.aluno,
      @required this.pedidoUid})
      : super(key: key);
  @override
  _FormularioOrientacaoState createState() => _FormularioOrientacaoState();
}

class _FormularioOrientacaoState extends State<FormularioOrientacao> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  DatabaseService banco = new DatabaseService();
  var diasDaSemana = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado'
  ];
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
  var horarioSabado = ["7:15 - 8:00",
    "8:00 - 8:45",
    "9:00 - 9:45",
    "9:45 - 10:30",
    "10:45 - 11:30",
    "11:30 - 12:15" ];
  //List<int> horas = new List<int>.generate(25, (i) => i);
  //List<int> minutos = new List<int>.generate(61, (i) => i);

  String curso = ''; // pegar do aluno
  String disciplina = 'CMP1071'; // pegar do banco
  String turma = ''; // pegar do banco
  String diaDaSemana = 'Selecione...';
  String horario = ' Selecione...';

  String professor = ''; // pegar do usuario
  String matriculaAluno = ''; // pegar do aluno
  String nomeAluno = ''; // pegar do aluno
  String error = '';
  List<DropdownMenuItem> listaHorarios;
  List<DropdownMenuItem> mostrarHorarioSabado() {
    return horarios.map((String diaEscolhido) {
      return DropdownMenuItem<String>(
        value: diaEscolhido,
        child: Text(diaEscolhido),
      );
    }).toList();
  }

  List<DropdownMenuItem> mostrarTodosHorarios() {
    return horarioSabado.map((String diaEscolhido) {
      return DropdownMenuItem<String>(
        value: diaEscolhido,
        child: Text(diaEscolhido),
      );
    }).toList();
  }

  DropdownButton mostrarHorario(List<String> lista) {
    return DropdownButton(
        hint: Text(horario),
        items: lista.map((String horarioEscolhido) {
          return DropdownMenuItem<String>(
            value: horarioEscolhido,
            child: Text(horarioEscolhido),
          );
        }).toList(),
        onChanged: (val) {
          print(val);
          setState(() {
            horario = val;
          });
        });
  }

  DropdownButton mostrarNull() {
    return DropdownButton(
        items: null,
        onChanged: (val) {
          null;
        });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
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
                          Text("Dia da semana:   ",
                              style: TextStyle(fontSize: 16)),
                          DropdownButton(
                            hint: Text(diaDaSemana),
                            items: diasDaSemana.map((String diaEscolhido) {
                              return DropdownMenuItem<String>(
                                value: diaEscolhido,
                                child: Text(diaEscolhido),
                              );
                            }).toList(),
                            onChanged: (val) {
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
                          Text(
                            "Horário:   ",
                            style: TextStyle(fontSize: 16),
                          ),
                          diaDaSemana == "Selecione..." ? mostrarNull() : diaDaSemana != "Sábado" ? mostrarHorario(horarios) : mostrarHorario(horarioSabado),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      RaisedButton(
                          color: Colors.blue,
                          child: Text(
                            "Confirmar",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (horario == 'Selecione...') {
                              setState(() {
                                error = 'Escolha um dia';
                                loading = false;
                              });
                            } else if (diaDaSemana == 'Selecione...') {
                              setState(() {
                                error = 'Escolha um horario';
                                loading = false;
                              });
                            } else {
                              if (_formKey.currentState.validate()) {
                                setState(() => loading = true);
                                curso = widget.aluno.curso;
                                professor = widget.user.nome;
                                matriculaAluno = widget.aluno.matricula;
                                nomeAluno = widget.aluno.nome;

                                //pegar contador do banco e montar turma
                                turma =
                                    await banco.getTurma(widget.aluno.curso);
                                print(turma);

                                //metodo do database para salvar orientação
                                //passar uid do pedido para remove-lo (excluido = 1)
                                try {
                                  banco.salvarOrientacao(
                                      curso,
                                      disciplina,
                                      turma,
                                      diaDaSemana,
                                      horario,
                                      professor,
                                      matriculaAluno,
                                      nomeAluno,
                                      widget.aluno.uid,
                                      widget.user.uid);
                                  banco.deletarPedido(widget.pedidoUid);
                                  banco.atualizarDisciplina(widget.aluno.uid, disciplina);
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  setState(() {
                                    error = 'Erro ao salvar orientação!';
                                    print(e);
                                    loading = false;
                                  });
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
