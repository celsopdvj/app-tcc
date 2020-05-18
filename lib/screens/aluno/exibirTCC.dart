import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_tcc/models/settingsTCC.dart';
import 'package:url_launcher/url_launcher.dart';

class ExibirTCC extends StatefulWidget {
  final User user;
  ExibirTCC({Key key, @required this.user}) : super(key: key);
  @override
  _ExibirTCCState createState() => _ExibirTCCState();
}

class _ExibirTCCState extends State<ExibirTCC> {
  String _searchText = "";
  int _radioValue = -1;

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possivel abrir o pdf';
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    ScrollController _controller = new ScrollController(keepScrollOffset: true);

    Stream<QuerySnapshot> getStreamTcc() {
      if (_searchText == "" || _radioValue == -1) {
        return Firestore.instance.collection('tcc').snapshots();
      }
      else if(_radioValue == 0){
        return Firestore.instance.collection('tcc').where('titulo',isEqualTo:_searchText).snapshots();
      }
      else if(_radioValue == 1){
        return Firestore.instance.collection('tcc').where('aluno',isEqualTo:_searchText).snapshots();
      }
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('TCCs'),
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('Sair', style: textStyle2.copyWith()),
              onPressed: () async {
                print(widget.user.uid);
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
            )
          ],
        ),
        body: StreamBuilder(
            stream: getStreamTcc(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return Loading();
              return GestureDetector(
                      onTap: () {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      },
                      child: Column(children: <Widget>[
                        Container(
                            child: Row(
                          children: <Widget>[
                            SizedBox(width: 10,),
                            Expanded(
                              child: TextFormField(
                                  decoration: InputDecoration(
                                      hintText: "Procurar...",
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white,
                                              width: 2.0))),
                                  onChanged: (val) {
                                    setState(() => _searchText = val);
                                  }),
                            ),
                            IconButton(
                              icon: Icon(Icons.search),
                              onPressed: () {
                                print(_searchText);
                                print(_radioValue);
                              },
                            )
                          ],
                        )),
                        Row(
                          children: <Widget>[
                            new Radio(
                                value: 0,
                                groupValue: _radioValue,
                                onChanged: (val) {
                                  print(val);
                                  setState(() {
                                    _radioValue = val;
                                  });
                                }),
                            new Text(
                              'Título',
                              style: new TextStyle(fontSize: 11.0),
                            ),
                            new Radio(
                              value: 1,
                              groupValue: _radioValue,
                              onChanged: (val) {
                                print(val);
                                setState(() {
                                  _radioValue = val;
                                });
                              },
                            ),
                            new Text(
                              'Autor',
                              style: new TextStyle(
                                fontSize: 11.0,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: new ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            controller: _controller,
                            children: snapshot.data.documents.map((document) {
                              return new Card(
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: Colors.black,
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                        title: Text("Título: " +
                                            document.data['titulo'].toString()),
                                        subtitle: Text("Autor: " +
                                            document.data['aluno'].toString()),
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              '/visualizarTCC',
                                              arguments: ScreenArgumentsTCC(
                                                  url: document.data['url'],
                                                  filename: document
                                                      .data['filename']));
                                        }),
                                    SizedBox(
                                      height: 12,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ]),
                    );
            }));
  }
}
