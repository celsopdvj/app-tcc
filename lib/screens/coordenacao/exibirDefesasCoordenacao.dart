import 'package:app_tcc/models/defesas.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ExibirDefesasCoordenacao extends StatefulWidget {
  @override
  _ExibirDefesasCoordenacaoState createState() =>
      _ExibirDefesasCoordenacaoState();
}

class _ExibirDefesasCoordenacaoState extends State<ExibirDefesasCoordenacao> {
  final AuthService _auth = AuthService();
  ScrollController _controller = new ScrollController(keepScrollOffset: true);
  List<Defesa> listaDefesas = new List<Defesa>();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  showNotification(
      String horario, String data, String nomeAluno, String sala) async {
    showDialog(
        context: context,
        builder: (context) => new AlertDialog(
              content: new Text(
                  'Deseja agendar uma notificação para 30 minutos antes dessa defesa?'),
              actions: <Widget>[
                new FlatButton(
                  textColor: Colors.white,
                  color: Colors.blue[300],
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
                    DateTime datetime = DateTime.parse(aux2.toString());
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
                        'Sala: ' + sala,
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
    for (DocumentSnapshot doc in snapshot.documents) {
      listaDefesas.add(new Defesa(
        id: doc.documentID,
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
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return Loading();
              listaDefesas = criarlistaDefesas(snapshot.data);
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _controller,
                children: listaDefesas.map(
                  (defesa) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          height: 220,
                          child: Card(
                            margin: EdgeInsets.all(10),
                            elevation: 5,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text("Aluno(a): "+defesa.nomeAluno),
                                  Text("Orientador(a): "+defesa.orientador),
                                  Text("Título do TCC: "+defesa.titulo),
                                  Text("Data: "+defesa.data+" "+defesa.horario),
                                  Text("Local: "+defesa.local)
                                ],
                              ),
                            ),
                          )),
                    );
                  },
                ).toList(),
              );
            }));
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
