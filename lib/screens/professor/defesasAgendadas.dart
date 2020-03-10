import 'package:app_tcc/models/defesas.dart';
import 'package:app_tcc/models/settingsFormDefesa.dart';
import 'package:app_tcc/models/settingsFormOrientacao.dart';
import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/database.dart';
import 'package:app_tcc/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DefesasAgendadas extends StatefulWidget {
  final User user;
  DefesasAgendadas({Key key, @required this.user}):super(key:key);
  @override
  _DefesasAgendadasState createState() => _DefesasAgendadasState();
}

class _DefesasAgendadasState extends State<DefesasAgendadas> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DatabaseService banco = new DatabaseService();
  String _alunoUid = '';
  Defesa defesa = new Defesa();

  void agendarDefesa( )async{
      Navigator.pushNamed(context, '/agendarDefesa', arguments:  widget.user);
  }

   @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    ScrollController _controller = new ScrollController();
    
    BoxDecoration myBoxDecorationGreen() {
      return BoxDecoration(
        border: Border.all(
          color: Colors.green, //                   <--- border color
          width: 2.0,
        ),
      );
    }

    BoxDecoration myBoxDecorationRed() {
      return BoxDecoration(
        border: Border.all(
          color: Colors.red, //                   <--- border color
          width: 2.0,
        ),
      );
    }

    BoxDecoration myBoxDecorationGray() {
      return BoxDecoration(
        border: Border.all(
          color: Colors.grey, //                   <--- border color
          width: 2.0,
        ),
      );
    }


    return  Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Defesas Pendentes'),
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
      stream: Firestore.instance.collection('defesa')
                                .where('uidOrientador' ,isEqualTo: widget.user.uid)
                                .where('pendente', isEqualTo: true)
                                .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Loading();
        return Column(
          children: <Widget>[
            Expanded(
                child: new ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _controller,
                  children: snapshot.data.documents.map((document) {
                    return new ListTile(
                      key: Key(document.documentID),
                      title: new Text("Aluno: " +document['nomeAluno']),
                      onTap: () {
                        defesa = new Defesa(id: document.documentID,data: document.data["data"],horario: document.data["horario"],
                        local: document.data["sala"], disciplina: document.data["disciplina"], nomeAluno: document.data["nomeAluno"],
                        titulo: document.data["titulo"], orientador: document.data["orientador"], coorientador: document.data["coOrientador"],
                        curso: document.data["curso"], uidAluno: document.data["uidAluno"], uidCoorientador: document.data["uidCoorientador"], 
                        uidOrientador: document.data["uidOrientador"], matriculaAluno: document.data["matriculaAluno"],
                        membroDaBanca1: document.data["membroDaBanca1"], membroDaBanca2: document.data["membroDaBanca2"], membroDaBanca3: document.data["membroDaBanca3"],
                        membroDaBanca4: document.data["membroDaBanca4"], membroDaBanca5: document.data["membroDaBanca5"], nomeMembroDaBanca1: document.data["nomeMembroDaBanca1"],
                        nomeMembroDaBanca2: document.data["nomeMembroDaBanca2"], nomeMembroDaBanca3: document.data["nomeMembroDaBanca3"], nomeMembroDaBanca4: document.data["nomeMembroDaBanca4"],
                        nomeMembroDaBanca5: document.data["nomeMembroDaBanca5"], statusConvite1: document.data["statusConvite1"], statusConvite2: document.data["statusConvite2"],
                        statusConvite3: document.data["statusConvite3"], statusConvite4: document.data["statusConvite4"], statusConvite5: document.data["statusConvite5"]);

                        Navigator.pushNamed(context, '/editarDefesa', arguments:  ScreenArgumentsDefesa(user: widget.user, defesa: defesa));
                      },
                      subtitle: Row(children: <Widget>[
                        Text("Banca: "),
                        SizedBox(width: 5.0),
                        Container(decoration: document.data["statusConvite1"] == 1 ? myBoxDecorationGreen() :
                          document.data["statusConvite1"] == 0 ? myBoxDecorationGray() : myBoxDecorationRed()
                          ,child: Text(document.data["nomeMembroDaBanca1"], ),),
                        SizedBox(width: 5.0),

                        Container(decoration: document.data["statusConvite2"] == 1 ? myBoxDecorationGreen() :
                          document.data["statusConvite2"] == 0 ? myBoxDecorationGray() : myBoxDecorationRed()
                          ,child: Text(document.data["nomeMembroDaBanca2"], ),),
                        SizedBox(width: 5.0),

                        document.data["statusConvite3"] == -1 ? Text("") : Container(decoration: document.data["statusConvite3"] == 1 ? myBoxDecorationGreen() :
                          document.data["statusConvite3"] == 0 ? myBoxDecorationGray() : myBoxDecorationRed()
                          ,child: Text(document.data["nomeMembroDaBanca3"], ),),
                        SizedBox(width: 5.0),

                        document.data["statusConvite4"] == -1 ? Text("") :Container(decoration: document.data["statusConvite4"] == 1 ? myBoxDecorationGreen() :
                          document.data["statusConvite4"] == 0 ? myBoxDecorationGray() : myBoxDecorationRed()
                          ,child: Text(document.data["nomeMembroDaBanca4"], ),),
                        SizedBox(width: 5.0),

                        document.data["statusConvite5"] == -1 ? Text("") :Container(decoration: document.data["statusConvite5"] == 1 ? myBoxDecorationGreen() :
                          document.data["statusConvite5"] == 0 ? myBoxDecorationGray() : myBoxDecorationRed()
                          ,child: Text(document.data["nomeMembroDaBanca5"], ),),
                        SizedBox(width: 5.0),

                        ]
                      ,),
                    );
                    }).toList(),
                  ),
              ),
              
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          RaisedButton(
                          color: Colors.blue,
                          child: Text("Agendar",style: TextStyle(color: Colors.white)),
                          onPressed: agendarDefesa,
                          ),
                        ],
                      )
                    ],
                  ),
              ),
            ],
          );
        },
        ),
      );
  }
}