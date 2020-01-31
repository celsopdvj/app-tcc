import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';

class FormularioDeDefesa extends StatefulWidget {
  final User user;
  final User aluno;
  FormularioDeDefesa({Key key, @required this.user, @required this.aluno}):super(key:key);
  @override
  _FormularioDeDefesaState createState() => _FormularioDeDefesaState();
}

class _FormularioDeDefesaState extends State<FormularioDeDefesa> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  String nomeAluno = ''; //tem aluno selecionado
  String matriculaAluno = ''; //tem aluno selecionado
  String disciplina = ''; //tem aluno selecionado
  String curso = ''; //tem aluno selecionado
  String titulo = '';
  String orientador = ''; //tem aluno selecionado
  String coorientador = '';
  TimeOfDay horario;
  DateTime data;
  String sala = '';
  String membroDaBanca1 = '';
  String membroDaBanca2 = '';
  String membroDabanca3 = '';
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

  Future<Null> _selectedDate(BuildContext context) async {
      data = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(DateTime.now().year),
          lastDate: DateTime(DateTime.now().year +1));
      if (data != null) {
        setState(() {
          data = data;
        });
      }
    }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              elevation: 0.0,
              title: Text('Formulário para agendar defesa'),
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
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
                        decoration: textInputDecoration.copyWith(hintText: 'Coorientador se possuir',
                          enabledBorder: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            borderSide: new BorderSide()),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            ),
                        ),
                        onChanged: (val) {
                          setState(() => coorientador = val);
                        }),
                      SizedBox(height: 20.0),
                      Row(
                        children: <Widget>[
                          Text("Data  ", style: TextStyle(fontSize: 16)),
                          FlatButton(
                              child: data == null ? Text("Selecione...", style: TextStyle(fontSize: 16, color: Colors.black38))
                                                    :Text(formatDate(data,[dd, '-', mm, '-', yyyy])),
                              onPressed: () => _selectedDate(context)
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
                        decoration: textInputDecoration.copyWith(hintText: 'Sala',
                          enabledBorder: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            borderSide: new BorderSide()),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            ),
                        ),
                        validator: (val) =>
                              val.isEmpty ? 'Digite uma sala.' : null,
                        onChanged: (val) {
                          setState(() => sala = val);
                        }),
                      SizedBox(height: 20.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: 'Primeiro membro da banca',
                          enabledBorder: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            borderSide: new BorderSide()),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            ),
                        ),
                        validator: (val) =>
                              val.isEmpty ? 'Digite o primeiro membro da banca.' : null, //professor?
                        onChanged: (val) {
                          setState(() => membroDaBanca1 = val);
                        }),
                      SizedBox(height: 20.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: 'Segundo membro da banca',
                          enabledBorder: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            borderSide: new BorderSide()),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            ),
                        ),
                        validator: (val) =>
                              val.isEmpty ? 'Digite o segundo membro da banca.' : null,
                        onChanged: (val) {
                          setState(() => membroDaBanca2 = val);
                        }),
                      SizedBox(height: 20.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: 'Terceiro membro da banca',
                          enabledBorder: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            borderSide: new BorderSide()),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            ),
                        ),
                        validator: (val) {
                          if(widget.aluno.disciplina != "CMP1071")
                            return 'Digite o terceiro membro da banca.';
                        },
                        onChanged: (val) {
                          setState(() => membroDabanca3 = val);
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
                              //setState(()=>loading=true);
                              nomeAluno = widget.aluno.nome;
                              matriculaAluno = widget.aluno.matricula;
                              disciplina = widget.aluno.disciplina;
                              curso = widget.aluno.curso;
                              orientador = widget.user.nome;
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