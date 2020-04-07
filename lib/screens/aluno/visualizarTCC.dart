import 'package:app_tcc/shared/loading.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class VisualizarTCC extends StatefulWidget {
  final String url;
  final String filename;
  VisualizarTCC({Key key, @required this.url, @required this.filename}) : super(key: key);
  @override
  _VisualizarTCCState createState() => _VisualizarTCCState();
}

class _VisualizarTCCState extends State<VisualizarTCC> {
  bool downloading = false;
  bool loading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PDFDocument document;
  var progressString = "";

  void carregarPDF() async {
    document = await PDFDocument.fromURL(widget.url);
    setState(() {
      loading = false;
    });
  }


  Widget downloadingWidget() {
    return Container(
                height: 120.0,
                width: 200.0,
                child: Card(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "Baixando pdf: $progressString",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              );
  }


  void downloadPDF() async { 
    Dio dio = Dio();
    var downloaddir;
    try {
      var dir = await getTemporaryDirectory();
      downloaddir = dir.path + '/' + widget.filename;
      await dio.download(widget.url, downloaddir, onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");

        setState(() {
          downloading = true;
          progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      
      progressString = "Download terminado";
      downloading = false;
    });
    print("Download completed");
    OpenFile.open(downloaddir);

  }

  @override
  void initState() {
    carregarPDF();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return downloading ? downloadingWidget() : loading ? Loading(): 
      Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
            label: Text(""),
            icon: Icon(Icons.file_download),
            onPressed: () async {
              downloadPDF();
            },
          )
          ],
        ),
        body: PDFViewer(document: document,));
  }
}

