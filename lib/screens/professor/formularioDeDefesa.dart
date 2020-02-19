import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/database.dart';
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
  DatabaseService banco = new DatabaseService();

  String nomeAluno = ''; //tem aluno selecionado
  String matriculaAluno = ''; //tem aluno selecionado
  String disciplina = ''; //tem aluno selecionado
  String curso = ''; //tem aluno selecionado
  String titulo = '';
  String orientador = ''; //tem aluno selecionado
  String uidCoorientador = '';
  String coorientador = '';
  TimeOfDay horario;
  DateTime data;
  String sala = '';
  User membroDaBanca1 = new User(nome: 'Selecione...');
  User membroDaBanca2 = new User(nome: 'Selecione...');
  User membroDaBanca3 = new User(nome: 'Selecione...');
  User membroDaBanca4 = new User(nome: 'Selecione...');
  User membroDaBanca5 = new User(nome: 'Selecione...');
  String error = '';
  List<User> professores = new List<User>();

  @override
  void initState(){
    super.initState();
    
      setState(() =>loading = true);
      banco.getProfessores().then((onValue){
        setState(()=>professores = onValue);
      });
      setState(() =>loading = false);

  }

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

  void agendarDefesa() async{
    await banco.salvarDefesa(nomeAluno, matriculaAluno, widget.aluno.uid, disciplina, curso,
     titulo, orientador, widget.user.uid, coorientador, uidCoorientador,
      formatDate(data,[dd, '-', mm, '-', yyyy]), horario.format(context),
       sala, membroDaBanca1.nome, membroDaBanca2.nome, membroDaBanca3.nome ,
       membroDaBanca4.nome == 'Selecione...'? '' : membroDaBanca4.nome ,membroDaBanca5.nome == 'Selecione...'? '' : membroDaBanca5.nome);
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
                      Row(
                        children: <Widget>[
                          Text('Primeiro membro da banca: '),
                          SizedBox(width: 4,),
                          DropdownButton(
                            hint: Text(membroDaBanca1.nome),
                            items: professores.map((membroEscolhido){
                              return DropdownMenuItem<User>(
                                value: membroEscolhido,
                                child: Text(membroEscolhido.nome)
                              );
                            }).toList(),
                            onChanged:(val){ 
                              setState(() {
                                professores.remove(val);
                                if(membroDaBanca1.nome != 'Selecione...')
                                  professores.add(membroDaBanca1);
                                membroDaBanca1 = val;
                              });
                            },
                          )
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        children: <Widget>[
                          Text('Segundo membro da banca:  '),
                          DropdownButton(
                            hint: Text(membroDaBanca2.nome),
                            items: professores.map((membroEscolhido){
                              return DropdownMenuItem<User>(
                                value: membroEscolhido,
                                child: Text(membroEscolhido.nome)
                              );
                            }).toList(),
                            onChanged:(val){ 
                              setState(() {
                                professores.remove(val);
                                if(membroDaBanca2.nome != 'Selecione...')
                                  professores.add(membroDaBanca2);
                                membroDaBanca2 = val;
                              });
                            },
                          )
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        children: <Widget>[
                          Text('Terceiro membro da banca: '),
                          DropdownButton(
                            hint: Text(membroDaBanca3.nome),
                            items: professores.map((membroEscolhido){
                              return DropdownMenuItem<User>(
                                value: membroEscolhido,
                                child: Text(membroEscolhido.nome)
                              );
                            }).toList(),
                            onChanged:(val){ 
                              setState(() {
                                professores.remove(val);
                                if(membroDaBanca3.nome != 'Selecione...')
                                  professores.add(membroDaBanca3);
                                membroDaBanca3 = val;
                              });
                            },
                          )
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        children: <Widget>[
                          Text('Quarto membro da banca: '),
                          DropdownButton(
                            hint: Text(membroDaBanca4.nome),
                            items: professores.map((membroEscolhido){
                              return DropdownMenuItem<User>(
                                value: membroEscolhido,
                                child: Text(membroEscolhido.nome)
                              );
                            }).toList(),
                            onChanged:(val){ 
                              setState(() {
                                professores.remove(val);
                                if(membroDaBanca4.nome != 'Selecione...')
                                  professores.add(membroDaBanca4);
                                membroDaBanca4 = val;
                              });
                            },
                          )
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        children: <Widget>[
                          Text('Quinto membro da banca: '),
                          DropdownButton(
                            hint: Text(membroDaBanca5.nome),
                            items: professores.map((membroEscolhido){
                              return DropdownMenuItem<User>(
                                value: membroEscolhido,
                                child: Text(membroEscolhido.nome)
                              );
                            }).toList(),
                            onChanged:(val){ 
                              setState(() {
                                professores.remove(val);
                                if(membroDaBanca5.nome != 'Selecione...')
                                  professores.add(membroDaBanca5);
                                membroDaBanca5 = val;
                              });
                            },
                          )
                        ],
                      ),
                      SizedBox(height: 20.0),
                      RaisedButton(
                          color: Colors.blue,
                          child: Text(
                            "Confirmar",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              setState(()=>loading=true);
                              if(membroDaBanca1.nome == 'Selecione...' ||
                              membroDaBanca2.nome == 'Selecione...' || (membroDaBanca3.nome == 'Selecione...' && widget.aluno.disciplina != "CMP1071"))
                                setState(() =>error = 'Selecione mais membros pra banca.');
                              else{
                                nomeAluno = widget.aluno.nome;
                                matriculaAluno = widget.aluno.matricula;
                                disciplina = widget.aluno.disciplina;
                                curso = widget.aluno.curso;
                                orientador = widget.user.nome;
                                agendarDefesa();
                                Navigator.pop(context);
                              }
                              setState(()=>loading=false);
                              //Navigator.pop(context);
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