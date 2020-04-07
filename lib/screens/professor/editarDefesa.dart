import 'package:app_tcc/models/defesas.dart';
import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';

class EditarDefesa extends StatefulWidget {
  final User user;
  Defesa defesa;
  EditarDefesa({Key key, @required this.user, @required this.defesa}):super(key:key);
  @override
  _EditarDefesaState createState() => _EditarDefesaState();
}

class _EditarDefesaState extends State<EditarDefesa> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  DatabaseService banco = new DatabaseService();

  User aluno;
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
  User membroDaBanca2 ;
  User membroDaBanca3 ;
  User membroDaBanca4 ;
  User membroDaBanca5 ;
  String error = '';
  List<User> professores = new List<User>();

  @override
  void initState(){
    super.initState();
    
      setState(() =>loading = true);
      banco.getProfessores().then((onValue){
        setState((){
          professores = onValue;
          professores.removeWhere((user) => user.nome == widget.defesa.nomeMembroDaBanca2);
          professores.removeWhere((user) => user.nome == widget.defesa.nomeMembroDaBanca3);
          professores.removeWhere((user) => user.nome == widget.defesa.nomeMembroDaBanca4);
          professores.removeWhere((user) => user.nome == widget.defesa.nomeMembroDaBanca5);
        });
      });
      setState(() {
        String d = widget.defesa.data;
        data = new DateTime(int.parse(d.split("-")[2]), int.parse(d.split("-")[1]), int.parse(d.split("-")[0]));
        String s = widget.defesa.horario;
        horario = TimeOfDay(hour:int.parse(s.split(":")[0]),minute: int.parse(s.split(":")[1]));
        //2
        if(widget.defesa.statusConvite2 == -2)
          membroDaBanca2 = new User();
        else
          membroDaBanca2 = new User(nome: widget.defesa.nomeMembroDaBanca2, uid: widget.defesa.membroDaBanca2);
        //3
        if(widget.defesa.statusConvite3 == -2)
          membroDaBanca3 = new User();
        else
          membroDaBanca3 = new User(nome: widget.defesa.nomeMembroDaBanca3, uid: widget.defesa.membroDaBanca3);
        //4
        if(widget.defesa.statusConvite4 == -2)
          membroDaBanca4 = new User();
        else
          membroDaBanca4 = new User(nome: widget.defesa.nomeMembroDaBanca4, uid: widget.defesa.membroDaBanca4);
        //5
        if(widget.defesa.statusConvite5 == -2)
          membroDaBanca5 = new User();
        else
          membroDaBanca5 = new User(nome: widget.defesa.nomeMembroDaBanca5, uid: widget.defesa.membroDaBanca5);

        loading = false;
      });

  }

  Future<Null> _selectedTime(BuildContext context) async {
      horario = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now());
      if (horario != null) {
        setState(() {
          horario = horario;
          widget.defesa.horario = horario.format(context);
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
          widget.defesa.data = formatDate(data,[dd, '-', mm, '-', yyyy]);
        });
      }
    }

  void agendarDefesa() async{
    print(widget.defesa);
    await banco.editarDefesa(widget.defesa);
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
                        initialValue: widget.defesa.titulo,
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
                          setState(() => widget.defesa.titulo = val);
                        }),
                      SizedBox(height: 20.0),
                      TextFormField(
                        initialValue: widget.defesa.coorientador,
                        decoration: textInputDecoration.copyWith(hintText: 'Coorientador se possuir',
                          enabledBorder: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            borderSide: new BorderSide()),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.horizontal(),
                            ),
                        ),
                        onChanged: (val) {
                          setState(() => widget.defesa.coorientador = val);
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
                        initialValue: widget.defesa.local,
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
                                widget.defesa.membroDaBanca2 = membroDaBanca2.uid;
                                widget.defesa.nomeMembroDaBanca2 = membroDaBanca2.nome;
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
                            hint: Text(membroDaBanca3.nome == null?"Selecione...":membroDaBanca3.nome),
                            items: membroDaBanca2.nome == "Selecione..." ? null : professores.map((membroEscolhido){
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
                                widget.defesa.membroDaBanca3 = membroDaBanca3.uid;
                                widget.defesa.nomeMembroDaBanca3 = membroDaBanca3.nome;
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
                            hint: Text(membroDaBanca4.nome == null?"Selecione...":membroDaBanca4.nome),
                            items: membroDaBanca3.nome == "Selecione..." ? null : professores.map((membroEscolhido){
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
                                widget.defesa.membroDaBanca4 = membroDaBanca4.uid;
                                widget.defesa.nomeMembroDaBanca4 = membroDaBanca4.nome;
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
                            hint: Text(membroDaBanca5.nome == null?"Selecione...":membroDaBanca5.nome),
                            items: membroDaBanca4.nome == "Selecione..." ? null : professores.map((membroEscolhido){
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
                                widget.defesa.membroDaBanca5 = membroDaBanca5.uid;
                                widget.defesa.nomeMembroDaBanca5 = membroDaBanca5.nome;
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
                              //verificar quantidade de membros escolhidos
                              if(
                              membroDaBanca2.nome == null || (membroDaBanca3.nome == null && aluno.disciplina != "CMP1071"))
                                setState(() =>error = 'Selecione mais membros pra banca.');
                              else{
                                if (membroDaBanca3.nome == null)
                                  membroDaBanca3.nome = "";

                                if (membroDaBanca4.nome == null)
                                  membroDaBanca4.nome = "";

                                if (membroDaBanca5.nome == null)
                                  membroDaBanca5.nome = "";
                                agendarDefesa();
                                Navigator.pop(context);
                                // Navigator.pop(context);
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