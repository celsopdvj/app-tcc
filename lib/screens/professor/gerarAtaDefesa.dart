import 'package:app_tcc/models/settingsFormOrientacao.dart';
import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/database.dart';
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
  GerarAtaDefesa({Key key, @required this.user}):super(key:key);
  @override
  _GerarAtaDefesaState createState() => _GerarAtaDefesaState();
}

class _GerarAtaDefesaState extends State<GerarAtaDefesa> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DatabaseService banco = new DatabaseService();
  String _alunoUid = '';

  pw.Column _buildMembrosBanca(DocumentSnapshot document) {
    String membro3="",membro4="",membro5="";
    if(document["nomeMembroDaBanca3"]!=""){
      membro3="    Membro 3: " + document['nomeMembroDaBanca3'];
    }
    if(document["nomeMembroDaBanca4"]!=""){
      membro3="    Membro 4: " + document['nomeMembroDaBanca4'];
    }
    if(document["nomeMembroDaBanca5"]!=""){
      membro3="    Membro 5: " + document['nomeMembroDaBanca5'];
    }
      return pw.Column(mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,children: <pw.Widget>[
        pw.Paragraph(text: "    Membro 1: " + document['nomeMembroDaBanca1']),
        pw.Paragraph(text: "Membro 2: " + document['nomeMembroDaBanca2']),
        membro3!=""?pw.Paragraph(text: membro3):membro4!=""?pw.Paragraph(text: membro4):membro5!=""?pw.Paragraph(text: membro5):pw.Text("")
      ]);
  }
  pw.Row _buildMembrosNota(DocumentSnapshot document) {
      return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,children: <pw.Widget>[
            pw.Column(children: <pw.Widget>[
              pw.Text('_________________'),
              pw.Text('(Nota Membro 1)')
            ]),
            pw.Column(children: <pw.Widget>[
              pw.Text('_________________'),
              pw.Text('(Nota Membro 2)')
            ]),
            pw.Column(children: <pw.Widget>[
              pw.Text('_________________'),
              pw.Text('(Nota Membro 3)')
            ]),
            pw.Column(children: <pw.Widget>[
              pw.Text('_________________'),
              pw.Text('(Média Final)')
            ])
          ]);
  }
  
  void gerarAta( DocumentSnapshot document)async{
    print('teste');
    final pw.Document doc = pw.Document();
    Directory appTempDirectory = await getTemporaryDirectory();
    const imageProvider = const AssetImage('assets/images/ata.png');
    final PdfImage image = await pdfImageFromImageProvider(pdf: doc.document, image: imageProvider);

    doc.addPage(pw.MultiPage(
        pageFormat:
            PdfPageFormat.a4,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        footer: (pw.Context context){
          return pw.Expanded(child: pw.Align(alignment: pw.Alignment.bottomRight,child: pw.Text('Goiânia, _____/_____/__________')));
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.Row(
            children: <pw.Widget>[
              pw.Image(image),
              pw.Expanded(
                child: pw.Expanded(
                  child: 
                    pw.Center(
                      
                      child: pw.Column(
                        children: <pw.Widget>[
                          pw.Paragraph(
                              text:
                                  'Pontifícia Universidade Católica de Goiás',style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Paragraph(
                              text:
                                  'Escola de Ciências Exatas e da Computação',style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Paragraph(
                              text:
                                  "Trabalho de Conclusão de Curso/Monografia",style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ]
                    ))))
            ]
          ),
          pw.Center(child: pw.Paragraph(text: 'ATA DE DEFESA',style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
          pw.Paragraph(text: ""),
          pw.Paragraph(text: 'Aluno(a): '+ document['nomeAluno']),
          pw.Paragraph(text: 'Matrícula: ' + document['matriculaAluno']),
          pw.Paragraph(text: 'Curso: '+document['curso']),
          pw.Paragraph(text: 'Título do trabalho: '+document['titulo']),
          pw.Paragraph(text: 'Disciplina: '+document['disciplina']),
          pw.Paragraph(text: 'Orientador(a): '+document['orientador']),
          pw.Row(children: <pw.Widget>[
            pw.Paragraph(text: 'Data: '+document['data'].toString().replaceAll('-', '/')+"    "),
            pw.Paragraph(text: 'Horário: '+document['horario']+"    "),
            pw.Paragraph(text: 'Sala: '+document['sala']+"    ")
          ]),
          pw.Paragraph(text: ""),
          pw.Paragraph(text: "Banca Examinadora: ",style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          _buildMembrosBanca(document),
          pw.Paragraph(text: "Avaliação do trabalho: (  ) Aprovado    (  ) Aprovado com correções   (  ) Reprovado"),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,children: <pw.Widget>[
            pw.Paragraph(text:"Considerações: "),
            pw.Paragraph(text: "___________________________________________________________________")
          ]),
          pw.Paragraph(text: "________________________________________________________________________________"),
          pw.Paragraph(text: "________________________________________________________________________________"),
          pw.Paragraph(text: "A banca examinadora indica o trabalho para publicação: (   ) Sim    (   ) Não"),
          _buildMembrosNota(document),
        ]));

    final File file = File('${appTempDirectory.path}/example.pdf');
    file.writeAsBytesSync(doc.save());
    OpenFile.open(file.path);
  }

   @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    ScrollController _controller = new ScrollController();

    return  Scaffold(
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
      stream: Firestore.instance.collection('defesa').where('pendente', isEqualTo:false).where('uidOrientador', isEqualTo:widget.user.uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Loading();
        return Column(
          children: <Widget>[
            Expanded(
                child: new ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _controller,
                  children: snapshot.data.documents.map((document) {
                    return GestureDetector(
                      onTap: ()=>gerarAta(document),
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
                                Text("Aluno: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(document['nomeAluno'])
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Data: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(document['data'])
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Horário: ", style: TextStyle(fontWeight: FontWeight.bold)),
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