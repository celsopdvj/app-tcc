import 'package:app_tcc/models/settingsFormOrientacao.dart';
import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/constants.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GerarAtaDefesa extends StatefulWidget {
  final User user;
  GerarAtaDefesa({Key key, @required this.user}) : super(key: key);
  @override
  _GerarAtaDefesaState createState() => _GerarAtaDefesaState();
}

class _GerarAtaDefesaState extends State<GerarAtaDefesa> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DatabaseService banco = new DatabaseService();
  String _alunoUid = '';

  int getQuantidadeMembrosBanca(DocumentSnapshot document) {
    int qntMembros = 2;
    if (document["nomeMembroDaBanca3"] != "") {
      qntMembros++;
      if (document["nomeMembroDaBanca4"] != "") {
        qntMembros++;
        if (document["nomeMembroDaBanca5"] != "") {
          qntMembros++;
        }
      }
    }
    return qntMembros;
  }

  pw.Column _buildMembrosBanca(DocumentSnapshot document) {
    List<pw.Widget> membros = new List<pw.Widget>();
    for (int i = 1; i <= getQuantidadeMembrosBanca(document); i++) {
      membros.add(pw.Text("    Membro " +
          i.toString() +
          ": " +
          document['nomeMembroDaBanca' + i.toString()]));
    }
    membros.add(pw.Paragraph(text: ""));
    return pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: membros);
  }

  pw.Widget _buildAssinaturas(DocumentSnapshot document) {
    List<pw.Widget> membros = new List<pw.Widget>();
    List<pw.Widget> membros1 = new List<pw.Widget>();
    List<pw.Widget> membros2 = new List<pw.Widget>();
    if (getQuantidadeMembrosBanca(document) > 3) {
      for (int i = 1; i <= 3; i++) {
        membros1.add(pw.Column(children: <pw.Widget>[
          pw.Text('_________________________________'),
          pw.Text('Assinatura Membro ' + i.toString()),
          pw.Padding(padding: pw.EdgeInsets.only(bottom:15)),
        ]));
      }

      for (int i = 4; i <= getQuantidadeMembrosBanca(document); i++) {
        membros2.add(pw.Column(children: <pw.Widget>[
          pw.Text('_________________________________'),
          pw.Text('Assinatura Membro ' + i.toString()),
          pw.Padding(padding: pw.EdgeInsets.only(bottom:15)),
        ]));
      }
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: <pw.Widget>[
          pw.Column(children: membros1),
          pw.Text("    "),
          pw.Column(children: membros2),
        ],
      );
    } else {
      for (int i = 1; i <= getQuantidadeMembrosBanca(document); i++) {
        membros.add(pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: <pw.Widget>[
              pw.Text('___________________________________________________'),
              pw.Text('Assinatura Membro ' + i.toString()),
              pw.Padding(padding: pw.EdgeInsets.only(bottom:15)),
            ]));
      }
    }

    return pw.Center(
        child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: membros));
  }

  pw.Row _buildMembrosNota(DocumentSnapshot document) {
    List<pw.Widget> membros = new List<pw.Widget>();
    for (int i = 1; i <= getQuantidadeMembrosBanca(document); i++) {
      membros.add(pw.Column(
          
          children: <pw.Widget>[
            pw.Text('___________  ',
                style: pw.TextStyle(decoration: pw.TextDecoration.underline)),
            pw.Text("Nota"),
            pw.Text('( Membro ' + i.toString() + ')')
          ]));
    }
    membros.add(pw.Column(children: <pw.Widget>[
      pw.Text('_____________  '),
      pw.Text('(Média Final)'),
      pw.Padding(padding: pw.EdgeInsets.only(bottom:15)),
    ]));
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start, children: membros);
  }

  void gerarAta(DocumentSnapshot document) async {
    print('teste');
    final pw.Document doc = pw.Document();
    Directory appTempDirectory = await getTemporaryDirectory();
    const imageProvider = const AssetImage('assets/images/ata.png');
    final PdfImage image = await pdfImageFromImageProvider(
        pdf: doc.document, image: imageProvider);

    doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        footer: (pw.Context context) {
          return pw.Expanded(
              child: pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Text('Goiânia, _____/_____/__________')));
        },
        build: (pw.Context context) => <pw.Widget>[
              pw.Row(children: <pw.Widget>[
                pw.Image(image),
                pw.Expanded(
                    child: pw.Expanded(
                        child: pw.Center(
                            child: pw.Column(children: <pw.Widget>[
                  pw.Paragraph(
                      text: 'Pontifícia Universidade Católica de Goiás',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Paragraph(
                      text: 'Escola de Ciências Exatas e da Computação',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Paragraph(
                      text: "Trabalho de Conclusão de Curso/Monografia",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]))))
              ]),
              pw.Center(
                  child: pw.Paragraph(
                      text: 'ATA DE DEFESA',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center)),
              pw.Paragraph(text: ""),
              pw.Text('Aluno(a): ' + document['nomeAluno']),
              pw.Text('Matrícula: ' + document['matriculaAluno']),
              pw.Text('Curso: ' + document['curso']),
              pw.Text('Título do trabalho: ' + document['titulo']),
              pw.Text('Disciplina: ' + document['disciplina']),
              pw.Text('Orientador(a): ' + document['orientador']),
              pw.Row(children: <pw.Widget>[
                pw.Text('Data: ' +
                    document['data'].toString().replaceAll('-', '/') +
                    "    "),
                pw.Text('Horário: ' + document['horario'] + "    "),
                pw.Text('Sala: ' + document['sala'] + "    ")
              ]),
              pw.Paragraph(text: ""),
              pw.Paragraph(
                  text: "Banca Examinadora: ",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              _buildMembrosBanca(document),
              pw.Paragraph(
                  text:
                      "Avaliação do trabalho: (  ) Aprovado    (  ) Aprovado com correções   (  ) Reprovado"),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: <pw.Widget>[
                    pw.Paragraph(text: "Considerações: "),
                    pw.Paragraph(
                        text:
                            "___________________________________________________________________")
                  ]),
              pw.Paragraph(
                  text:
                      "________________________________________________________________________________"),
              pw.Paragraph(
                  text:
                      "________________________________________________________________________________"),
              pw.Paragraph(
                  text:
                      "A banca examinadora indica o trabalho para publicação: (   ) Sim    (   ) Não"),
              _buildMembrosNota(document),
              pw.Paragraph(text: ""),
              pw.Paragraph(text: ""),
              _buildAssinaturas(document)
            ]));

    final File file = File(
        '${appTempDirectory.path}/AtaDeDefesa${document['nomeAluno'].replaceAll(new RegExp(r"\s+\b|\b\s"), "")}.pdf');
    print(file.path.toString());
    file.writeAsBytesSync(doc.save());
    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    ScrollController _controller = new ScrollController(keepScrollOffset: true);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Escolha uma defesa'),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('Sair'),
            onPressed: () async {
              print(widget.user.uid);
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
            .where('uidOrientador', isEqualTo: widget.user.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Loading();
          return snapshot.data.documents.length == 0
              ? Column(children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                      child: Text(
                    "Não há orientados para gerar ata!",
                    style: textStyle,
                  ))
                ])
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: new ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _controller,
                        children: snapshot.data.documents.map((document) {
                          return GestureDetector(
                            onTap: () => gerarAta(document),
                            child: new Card(
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: Colors.black,
                                  width: 0.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("Aluno: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(document['nomeAluno'])
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("Data: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(document['data'])
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("Horário: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(document['horario'])
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
