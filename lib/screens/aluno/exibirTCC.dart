import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ExibirTCC extends StatefulWidget {
  final User user;
  ExibirTCC({Key key, @required this.user}) : super(key: key);
  @override
  _ExibirTCCState createState() => _ExibirTCCState();
}

class _ExibirTCCState extends State<ExibirTCC> {
  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possivel abrir o pdf';
    }
  }

  // pdfView(url) => FutureBuilder<PDFDocument>(
  //   // Open document
  //   future: PDFDocument.openAsset(url),
  //   builder: (_, snapshot) {
  //     if (snapshot.hasData) {
  //       // Show document
  //       return PDFView(document: snapshot.data);
  //     }

  //     if (snapshot.hasError) {
  //       // Catch
  //       return Center(
  //         child: Text(
  //           'PDF Rendering does not '
  //           'support on the system of this version',
  //         ),
  //       );
  //     }

  //     return Center(child: CircularProgressIndicator());
  //   },
  // );

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    ScrollController _controller = new ScrollController();
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('TCCs'),
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('logout'),
              onPressed: () async {
                print(widget.user.uid);
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
            )
          ],
        ),
        body: StreamBuilder(
            stream: Firestore.instance.collection('tcc').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return Loading();
              return Column(children: <Widget>[
                Expanded(
                  child: new ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _controller,
                    children: snapshot.data.documents.map((document) {
                      return new Card(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                                title: Text(document.data['titulo'].toString()),
                                subtitle:
                                    Text(document.data['aluno'].toString()),
                                onTap: ()  {
                                    Navigator.of(context).pushNamed('/visualizarTCC', arguments: document.data['url']);
                                }
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ]);
            }));
  }
}
