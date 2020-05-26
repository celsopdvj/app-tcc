import 'package:app_tcc/models/defesas.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ExibirDefesas extends StatefulWidget {
  @override
  _ExibirDefesasState createState() => _ExibirDefesasState();
}

class _ExibirDefesasState extends State<ExibirDefesas> {
  final AuthService _auth = AuthService();
  List<Defesa> listaDefesas = new List<Defesa>();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool listaCriada = false;
  bool _sortNomeAlunoAsc = true;
  bool _sortOrientadorAsc = true;
  bool _sortAsc = true;
  int _sortColumnIndex;

  void sortAluno(int columnIndex, bool sortAscending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sortAsc = _sortNomeAlunoAsc = sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAsc = _sortNomeAlunoAsc;
      }
      listaDefesas.sort((a, b) => a.nomeAluno.compareTo(b.nomeAluno));
      if (!sortAscending) {
        listaDefesas = listaDefesas.reversed.toList();
      }
    });
  }

  void sortProfessor(int columnIndex, bool sortAscending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sortAsc = _sortOrientadorAsc = sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAsc = _sortOrientadorAsc;
      }
      listaDefesas.sort((a, b) => a.orientador.compareTo(b.orientador));
      if (!sortAscending) {
        listaDefesas = listaDefesas.reversed.toList();
      }
    });
  }

  void sortTitulo(int columnIndex, bool sortAscending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sortAsc = _sortOrientadorAsc = sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAsc = _sortOrientadorAsc;
      }
      listaDefesas.sort((a, b) => a.titulo.compareTo(b.titulo));
      if (!sortAscending) {
        listaDefesas = listaDefesas.reversed.toList();
      }
    });
  }

  void sortDisciplina(int columnIndex, bool sortAscending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sortAsc = _sortOrientadorAsc = sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAsc = _sortOrientadorAsc;
      }
      listaDefesas.sort((a, b) => a.disciplina.compareTo(b.disciplina));
      if (!sortAscending) {
        listaDefesas = listaDefesas.reversed.toList();
      }
    });
  }

  void sortDia(int columnIndex, bool sortAscending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sortAsc = _sortOrientadorAsc = sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAsc = _sortOrientadorAsc;
      }
      listaDefesas.sort((a, b) => a.data.compareTo(b.data));
      if (!sortAscending) {
        listaDefesas = listaDefesas.reversed.toList();
      }
    });
  }

  void sortHorario(int columnIndex, bool sortAscending) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sortAsc = _sortOrientadorAsc = sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAsc = _sortOrientadorAsc;
      }
      listaDefesas.sort((a, b) => a.horario.compareTo(b.horario));
      if (!sortAscending) {
        listaDefesas = listaDefesas.reversed.toList();
      }
    });
  }

  showNotification(
      String horario, String data, String nomeAluno, String sala) async {
    showDialog(
        context: context,
        builder: (context) => new AlertDialog(
              content: new Text(
                  'Deseja agendar uma notificação para 30 minutos antes dessa defesa?'),
              actions: <Widget>[
                new FlatButton(
                  textColor: Colors.red,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text('Não'),
                ),
                new FlatButton(
                  textColor: Colors.white,
                  color: Colors.blue[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),
                  ),
                  onPressed: () async {
                    var aux = data.split('-');
                    var aux2 = aux[2] +
                        '-' +
                        aux[1] +
                        '-' +
                        aux[0] +
                        " " +
                        horario.padLeft(5, '0');
                    print(aux2);
                    DateTime datetime = DateTime.parse(aux2.toString());
                    print(datetime);
                    var android = new AndroidNotificationDetails(
                        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
                        importance: Importance.Max, priority: Priority.High);
                    var iOS = new IOSNotificationDetails();
                    var plataform = new NotificationDetails(android, iOS);
                    var scheduledNotificationDateTime =
                        datetime.subtract(Duration(minutes: 30));
                    await flutterLocalNotificationsPlugin.schedule(
                        0,
                        'A defesa de: ' + nomeAluno + " vai começar!",
                        'Local: ' + sala,
                        scheduledNotificationDateTime,
                        plataform,
                        androidAllowWhileIdle: true);
                    showDialog(
                        context: context,
                        builder: (context) => new AlertDialog(
                              content: new Text('Notificação agendada!'),
                              actions: <Widget>[
                                new FlatButton(
                                  textColor: Colors.white,
                                  color: Colors.blue[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(18.0),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                    Navigator.of(context).pop(false);
                                  },
                                  child: new Text('Ok'),
                                ),
                              ],
                            ));
                  },
                  child: new Text('Sim'),
                ),
              ],
            ));
  }

  List<Defesa> criarlistaDefesas(QuerySnapshot snapshot) {
    listaDefesas = new List<Defesa>();
    for (DocumentSnapshot doc in snapshot.documents) {
      listaDefesas.add(new Defesa(
        data: doc.data['data'],
        horario: doc['horario'],
        local: doc['sala'],
        disciplina: doc['disciplina'],
        nomeAluno: doc.data['nomeAluno'],
        titulo: doc.data['titulo'],
        orientador: doc.data['orientador'],
      ));
    }
    return listaDefesas;
  }

  List<DataRow> _createRows2(List<Defesa> lista) {
    List<DataRow> newlist = new List<DataRow>();
    for (Defesa defesas in lista) {
      List<DataCell> newListCell = new List<DataCell>();
      newListCell.add(DataCell(Text(
        defesas.data,
        style: textStyle,
      )));
      newListCell.add(DataCell(Text(
        defesas.horario,
        style: textStyle,
      )));
      newListCell.add(DataCell(Text(
        defesas.local,
        style: textStyle,
      )));
      newListCell.add(DataCell(Text(
        defesas.disciplina,
        style: textStyle,
      )));
      newListCell.add(DataCell(Text(
        defesas.nomeAluno,
        style: textStyle,
      )));
      newListCell.add(DataCell(Text(
        defesas.titulo,
        style: textStyle,
      )));
      newListCell.add(DataCell(Text(
        defesas.orientador,
        style: textStyle,
      )));
      newListCell.add(DataCell(IconButton(
        onPressed: () async => showNotification(
            defesas.horario, defesas.data, defesas.nomeAluno, defesas.local),
        icon: Icon(Icons.add_alert),
      )));
      newlist.add(DataRow(cells: newListCell));
    }
    return newlist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Defesas'),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('Sair', style: textStyle2.copyWith()),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('defesa')
            .where('pendente', isEqualTo: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Loading();
          if (!listaCriada) {
            listaDefesas = criarlistaDefesas(snapshot.data);
            listaCriada = true;
          }
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: new DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAsc,
                columns: <DataColumn>[
                  new DataColumn(
                    onSort: (columnIndex, sortAscending) =>
                        sortDia(columnIndex, sortAscending),
                      label: Text(
                    'Dia',
                    style: textStyle,
                  )),
                  new DataColumn(
                    onSort: (columnIndex, sortAscending) =>
                        sortHorario(columnIndex, sortAscending),
                      label: Text(
                    'Horário',
                    style: textStyle,
                  )),
                  new DataColumn(
                      label: Text(
                    'Local',
                    style: textStyle,
                  )),
                  new DataColumn(
                    onSort: (columnIndex, sortAscending) =>
                        sortDisciplina(columnIndex, sortAscending),
                      label: Text(
                    'Disciplina',
                    style: textStyle,
                  )),
                  new DataColumn(
                    onSort: (columnIndex, sortAscending) =>
                        sortAluno(columnIndex, sortAscending),
                    label: Text(
                      'Aluno(a)',
                      style: textStyle,
                    ),
                  ),
                  new DataColumn(
                      onSort: (columnIndex, sortAscending) =>
                          sortTitulo(columnIndex, sortAscending),
                      label: Text('Título', style: textStyle)),
                  new DataColumn(
                      onSort: (columnIndex, sortAscending) =>
                          sortProfessor(columnIndex, sortAscending),
                      label: Text(
                        'Orientador(a)',
                        style: textStyle,
                      )),
                  new DataColumn(
                      label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Agendar',
                        style: textStyle,
                      ),
                      Text(
                        'alerta',
                        style: textStyle,
                      )
                    ],
                  ))
                ],
                rows: _createRows2(listaDefesas),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NotificationPlugin {
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  NotificationPlugin() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final initializationSettingsAndroid =
        AndroidInitializationSettings('secondary_icon');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
      initializationSettingsAndroid,
      initializationSettingsIOS,
    );
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      print('notification payload: ' + payload);
    }
  }

  Future<void> showWeeklyAtDayAndTime(
      Time time, Day day, int id, String title, String description) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'show weekly channel id',
      'show weekly channel name',
      'show weekly description',
    );
    final iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      id,
      title,
      description,
      day,
      time,
      platformChannelSpecifics,
    );
  }

  Future<void> showDailyAtTime(
      Time time, int id, String title, String description) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'show weekly channel id',
      'show weekly channel name',
      'show weekly description',
    );
    final iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.showDailyAtTime(
      id,
      title,
      description,
      time,
      platformChannelSpecifics,
    );
  }

  Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    final pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotifications;
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
