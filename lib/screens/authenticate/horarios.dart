import 'package:app_tcc/models/horario.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/database.dart';
import '../../shared/loading.dart';

class Horarios extends StatefulWidget {
  final User user;
  Horarios({Key key, @required this.user}) : super(key: key);
  @override
  _HorariosState createState() => _HorariosState();
}

class _HorariosState extends State<Horarios> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();
  bool loading = false;
  String error = '';
  List<Horario> listaSegunda = new List<Horario>();
  List<Horario> listaTerca = new List<Horario>();
  List<Horario> listaQuarta = new List<Horario>();
  List<Horario> listaQuinta = new List<Horario>();
  List<Horario> listaSexta = new List<Horario>();
  List<Horario> listaSabado = new List<Horario>();
  var diasDaSemana = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado'
  ];
  var horarios = [
    "7:15 - 8:45",
    "9:00 - 10:30",
    "10:45 - 12:15",
    "13:30 - 15:00",
    "15:15 - 16:45",
    "17:00 - 18:30",
    "18:45 - 20:15",
    "20:30 - 22:00"
  ];
  var horarioSabado = ["7:15 - 8:45", "9:00 - 10:30", "10:45 - 12:15"];

  void iniciarHorarios(List<Horario> lista, String dia) {
    int i = 0;
    for (var horario in horarios) {
      i++;
      String horarioInicial = horario.split(" - ")[0];
      String horarioFinal = horario.split(" - ")[1];
      lista.add(new Horario(
          dia: dia,
          nome: "Aula" + i.toString(),
          horarioInicial: horarioInicial,
          horarioFinal: horarioFinal,
          possui: false));
    }
  }

  void iniciarHorariosSabado() {
    int i = 0;
    for (var horario in horarioSabado) {
      i++;
      String horarioInicial = horario.split(" - ")[0];
      String horarioFinal = horario.split(" - ")[1];
      listaSabado.add(new Horario(
          dia: "Sábado",
          nome: "Aula" + i.toString(),
          horarioInicial: horarioInicial,
          horarioFinal: horarioFinal,
          possui: false));
    }
  }

  @override
  void initState() {
    setState(() {
      loading = true;
    });
    iniciarHorarios(listaSegunda, "Segunda");
    iniciarHorarios(listaTerca, "Terça");
    iniciarHorarios(listaQuarta, "Quarta");
    iniciarHorarios(listaQuinta, "Quinta");
    iniciarHorarios(listaSexta, "Sexta");
    iniciarHorariosSabado();
    super.initState();
    setState(() {
      loading = false;
    });
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(),
      borderRadius: BorderRadius.all(Radius.circular(18))
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    bool val = false;
    ScrollController _controller = new ScrollController(keepScrollOffset: true);
    //colocar no init

    return loading
        ? Loading()
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Horários'),
              elevation: 0.0,
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(height: 12,),
                  Container(
                    margin: new EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: myBoxDecoration(),
                    child: Column(
                      children: <Widget>[
                        Text("Segunda", style: textStyle),
                        CheckboxListTile(
                          title: Text("Aula 1"),
                          subtitle: Text("7:15 - 8:45"),
                          value: listaSegunda[0].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSegunda[0].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 2"),
                          subtitle: Text("9:00 - 10:30"),
                          value: listaSegunda[1].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSegunda[1].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 3"),
                          subtitle: Text("10:45 - 12:15"),
                          value: listaSegunda[2].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSegunda[2].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 4"),
                          subtitle: Text("13:30 - 15:00"),
                          value: listaSegunda[3].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSegunda[3].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 5"),
                          subtitle: Text("15:15 - 16:45"),
                          value: listaSegunda[4].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSegunda[4].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 6"),
                          subtitle: Text("17:00 - 18:30"),
                          value: listaSegunda[5].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSegunda[5].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 7"),
                          subtitle: Text("18:45 - 20:15"),
                          value: listaSegunda[6].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSegunda[6].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 8"),
                          subtitle: Text("20:30 - 22:00"),
                          value: listaSegunda[7].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSegunda[7].possui = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12,),
                  Container(
                    margin: new EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: myBoxDecoration(),
                    child: Column(
                      children: <Widget>[
                        Text("Terça", style: textStyle),
                        CheckboxListTile(
                          title: Text("Aula 1"),
                          subtitle: Text("7:15 - 8:45"),
                          value: listaTerca[0].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaTerca[0].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 2"),
                          subtitle: Text("9:00 - 10:30"),
                          value: listaTerca[1].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaTerca[1].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 3"),
                          subtitle: Text("10:45 - 12:15"),
                          value: listaTerca[2].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaTerca[2].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 4"),
                          subtitle: Text("13:30 - 15:00"),
                          value: listaTerca[3].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaTerca[3].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 5"),
                          subtitle: Text("15:15 - 16:45"),
                          value: listaTerca[4].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaTerca[4].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 6"),
                          subtitle: Text("17:00 - 18:30"),
                          value: listaTerca[5].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaTerca[5].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 7"),
                          subtitle: Text("18:45 - 20:15"),
                          value: listaTerca[6].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaTerca[6].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 8"),
                          subtitle: Text("20:30 - 22:00"),
                          value: listaTerca[7].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaTerca[7].possui = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12,),
                  Container(
                    margin: new EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: myBoxDecoration(),
                    child: Column(
                      children: <Widget>[
                        Text("Quarta", style: textStyle),
                        CheckboxListTile(
                          title: Text("Aula 1"),
                          subtitle: Text("7:15 - 8:45"),
                          value: listaQuarta[0].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuarta[0].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 2"),
                          subtitle: Text("9:00 - 10:30"),
                          value: listaQuarta[1].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuarta[1].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 3"),
                          subtitle: Text("10:45 - 12:15"),
                          value: listaQuarta[2].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuarta[2].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 4"),
                          subtitle: Text("13:30 - 15:00"),
                          value: listaQuarta[3].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuarta[3].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 5"),
                          subtitle: Text("15:15 - 16:45"),
                          value: listaQuarta[4].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuarta[4].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 6"),
                          subtitle: Text("17:00 - 18:30"),
                          value: listaQuarta[5].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuarta[5].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 7"),
                          subtitle: Text("18:45 - 20:15"),
                          value: listaQuarta[6].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuarta[6].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 8"),
                          subtitle: Text("20:30 - 22:00"),
                          value: listaQuarta[7].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuarta[7].possui = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12,),
                  Container(
                    margin: new EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: myBoxDecoration(),
                    child: Column(
                      children: <Widget>[
                        Text("Quinta", style: textStyle),
                        CheckboxListTile(
                          title: Text("Aula 1"),
                          subtitle: Text("7:15 - 8:45"),
                          value: listaQuinta[0].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuinta[0].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 2"),
                          subtitle: Text("9:00 - 10:30"),
                          value: listaQuinta[1].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuinta[1].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 3"),
                          subtitle: Text("10:45 - 12:15"),
                          value: listaQuinta[2].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuinta[2].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 4"),
                          subtitle: Text("13:30 - 15:00"),
                          value: listaQuinta[3].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuinta[3].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 5"),
                          subtitle: Text("15:15 - 16:45"),
                          value: listaQuinta[4].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuinta[4].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 6"),
                          subtitle: Text("17:00 - 18:30"),
                          value: listaQuinta[5].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuinta[5].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 7"),
                          subtitle: Text("18:45 - 20:15"),
                          value: listaQuinta[6].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuinta[6].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 8"),
                          subtitle: Text("20:30 - 22:00"),
                          value: listaQuinta[7].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaQuinta[7].possui = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 12,),
                  Container(
                    margin: new EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: myBoxDecoration(),
                    child: Column(
                      children: <Widget>[
                        Text("Sexta", style: textStyle),
                        CheckboxListTile(
                          title: Text("Aula 1"),
                          subtitle: Text("7:15 - 8:45"),
                          value: listaSexta[0].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSexta[0].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 2"),
                          subtitle: Text("9:00 - 10:30"),
                          value: listaSexta[1].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSexta[1].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 3"),
                          subtitle: Text("10:45 - 12:15"),
                          value: listaSexta[2].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSexta[2].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 4"),
                          subtitle: Text("13:30 - 15:00"),
                          value: listaSexta[3].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSexta[3].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 5"),
                          subtitle: Text("15:15 - 16:45"),
                          value: listaSexta[4].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSexta[4].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 6"),
                          subtitle: Text("17:00 - 18:30"),
                          value: listaSexta[5].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSexta[5].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 7"),
                          subtitle: Text("18:45 - 20:15"),
                          value: listaSexta[6].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSexta[6].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 8"),
                          subtitle: Text("20:30 - 22:00"),
                          value: listaSexta[7].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSexta[7].possui = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  //REVER QUANTAS AULAS TEM
                  SizedBox(height: 12,),
                  Container(
                    margin: new EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: myBoxDecoration(),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Sábado",
                          style: textStyle,
                        ),
                        CheckboxListTile(
                          title: Text("Aula 1"),
                          subtitle: Text("7:15 - 8:45"),
                          value: listaSabado[0].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSabado[0].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 2"),
                          subtitle: Text("9:00 - 10:30"),
                          value: listaSabado[1].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSabado[1].possui = val;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text("Aula 3"),
                          subtitle: Text("10:45 - 12:15"),
                          value: listaSabado[2].possui,
                          onChanged: (bool val) {
                            setState(() {
                              listaSabado[2].possui = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

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
                        setState(() {
                          loading = true;
                        });
                        print(listaSegunda);
                        dynamic result;
                        result = await _auth.registroDeUsuario(
                            widget.user.matricula,
                            widget.user.senha,
                            widget.user.nome,
                            "",
                            widget.user.email,
                            widget.user.telefone,
                            widget.user.tipoUsuario,
                            widget.user.areaAtuacao,
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
                        } else {
                          await DatabaseService().salvarHorario(
                              result.uid,
                              listaSegunda,
                              listaTerca,
                              listaQuarta,
                              listaQuinta,
                              listaSexta,
                              listaSabado);
                          Navigator.pushReplacementNamed(
                              context, '/homeProfessor',
                              arguments: result);
                        }
                      }),
                  SizedBox(height: 12.0),
                  Text(error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0))
                ],
              ),
            ));
  }
}
