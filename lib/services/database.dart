import 'package:app_tcc/models/defesas.dart';
import 'package:app_tcc/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/horario.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});
  // collection reference
  final CollectionReference usuario = Firestore.instance.collection('usuario');
  final CollectionReference pedidoPendente =
      Firestore.instance.collection('pedidoPendente');
  final CollectionReference orientacao =
      Firestore.instance.collection('orientacao');
  final CollectionReference orientacoes =
      Firestore.instance.collection('orientacao/turmas/orientacoes');
  final CollectionReference defesa = Firestore.instance.collection('defesa');
  final CollectionReference tcc = Firestore.instance.collection('tcc');

  Future updateUserData(
      String matricula,
      String senha,
      String nome,
      String email,
      String curso,
      String telefone,
      String tipoUsuario,
      String areaAtuacao,
      bool pedidoPendente) async {
    if (tipoUsuario == "Aluno") {
      return await usuario.document(uid).setData({
        'matricula': matricula,
        'nome': nome,
        'orientador': "",
        'email': email,
        'curso': curso,
        'telefone': telefone,
        'tipo': tipoUsuario,
        'areaAtuacao': areaAtuacao,
        'pedidoPendente': pedidoPendente,
        'defesaAgendada': "",
        'defesaPendente': "",
        'disciplina': ''
      });
    } else {
      return await usuario.document(uid).setData({
        'matricula': matricula,
        'nome': nome,
        'orientador': "",
        'email': email,
        'curso': curso,
        'telefone': telefone,
        'tipo': tipoUsuario,
        'areaAtuacao': areaAtuacao,
        'pedidoPendente': false
      });
    }
  }

  Future updatePedidoPendente(String uidAluno, String uidOrientador,
      String nomeAluno, String nomeProfessor, String disciplina) async {
    await pedidoPendente.document().setData({
      'uidAluno': uidAluno,
      'uidProfessor': uidOrientador,
      'nomeAluno': nomeAluno,
      'nomeProfessor': nomeProfessor,
      'validado': false,
      'excluido': 0,
      'disciplina': disciplina
    });
    return await usuario
        .document(uidAluno)
        .updateData({'pedidoPendente': true});
  }

  void desabilitaPedidoPendente(String uid) async {
    usuario.document(uid).updateData({'pedidoPendente': true});
  }

  Future<bool> getPedidoPendente(String uid) async {
    final result = await usuario.document(uid).get();
    return result.data['pedidoPendente'];
  }

  Future<bool> deletaPedidoPendenteDoAluno(String uidAluno) async {
    try {
      final aux = await pedidoPendente
          .where("uidAluno", isEqualTo: uidAluno)
          .getDocuments();
      final x = aux.documents.first;
      await pedidoPendente.document(x.documentID).delete();
      await usuario.document(uidAluno).updateData({'pedidoPendente': false});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void validaPedidoPendente(String uidDoc) async {
    await pedidoPendente.document(uidDoc).updateData({'validado': true});
  }

  Future getUser(String uid) async {
    final result = await usuario.document(uid).get();
    return new User(
        uid: uid,
        curso: result.data['curso'],
        matricula: result.data['matricula'],
        nome: result.data['nome'],
        email: result.data['email'],
        disciplina: result.data['disciplina']);
  }

  Future getTurma(String curso) async {
    // final snapShot = await orientacao.document('turmas').get();
    // if (curso == 'Engenharia de Computação' ||
    //     curso == 'Ciência da Computação') {
    //   await orientacao
    //       .document('turmas')
    //       .updateData({'contadorA': FieldValue.increment(1)});
    //   return "A" + snapShot.data['contadorA'].toString().padLeft(2, '0');
    // } else {
    //   await orientacao
    //       .document('turmas')
    //       .updateData({'contadorC': FieldValue.increment(1)});
    //   return "C" + snapShot.data['contadorC'].toString().padLeft(2, '0');
    // }
    if (curso == 'Engenharia de Computação' ||
        curso == 'Ciência da Computação') {
      var result =
          await orientacoes.where('curso', isEqualTo: curso).getDocuments();
      if (result.documents.length == 0) {
        return "A01";
      } else {
        String aux = "";
        int i = 1;
        bool achouTurma = false;
        while (!achouTurma) {
          aux = "A" + i.toString().padLeft(2, '0');
          var result =
              await orientacoes.where('turma', isEqualTo: aux).getDocuments();
          if (result.documents.length == 0) {
            return aux;
          } else {
            i++;
          }
        }
      }
    } else {
      var result =
          await orientacoes.where('curso', isEqualTo: curso).getDocuments();
      if (result.documents.length == 0) {
        return "C01";
      } else {
        String aux = "";
        int i = 1;
        bool achouTurma = false;
        while (!achouTurma) {
          aux = "C" + i.toString().padLeft(2, '0');
          var result =
              await orientacoes.where('turma', isEqualTo: aux).getDocuments();
          if (result.documents.length == 0) {
            return aux;
          } else {
            i++;
          }
        }
      }
    }
  }

  void salvarOrientacao(
      String curso,
      String disciplina,
      String turma,
      String dia,
      String horario,
      String nomeProfessor,
      String matriculaAluno,
      String nomeAluno,
      String uidAluno,
      String uidProfessor) async {
    await orientacoes.document().setData({
      'curso': curso,
      'disciplina': disciplina,
      'turma': turma,
      'dia': dia,
      'horario': horario,
      'nomeProfessor': nomeProfessor,
      'matricula': matriculaAluno,
      'nomeAluno': nomeAluno,
      'uidAluno': uidAluno,
      'uidProfessor': uidProfessor
    });
    usuario.document(uidAluno).updateData({'orientador': uidProfessor});
  }

  void deletarOrientacao(String id) async {
    var alunoDOC = await orientacoes.document(id).get();
    String alunoID = alunoDOC.data['uidAluno'];
    await orientacoes.document(id).delete();
    await usuario.document(alunoID).updateData({'orientador': ""});
  }

  void editarOrientacao(String uid, String dia, String horario) async {
    orientacoes.document(uid).updateData({'dia': dia, 'horario': horario});
  }

  void deletarPedido(String pedidoUid) async {
    final result = await pedidoPendente.document(pedidoUid).get();
    this
        .usuario
        .document(result.data['uidAluno'])
        .updateData({'pedidoPendente': false});
    await pedidoPendente.document(pedidoUid).delete();
  }

  Future getOrientador(String uid) async {
    final result = await usuario.document(uid).get();
    return result.data['orientador'];
  }

  Future getOrientacoes() async {
    final result = await orientacoes.getDocuments();
    return result.documents;
  }

  Future getDefesas() async {
    final result =
        await defesa.where('pendente', isEqualTo: false).getDocuments();
    return result.documents;
  }

  Future salvarDefesa(
      String nomeAluno,
      String matriculaAluno,
      String uidAluno,
      String disciplina,
      String curso,
      String titulo,
      String orientador,
      String uidOrientador,
      String coOrientador,
      String uidCoorientador,
      String data,
      String horario,
      String sala,
      User membroDaBanca2,
      User membroDaBanca3,
      User membroDaBanca4,
      User membroDaBanca5) async {
    var result = await defesa.add({
      'nomeAluno': nomeAluno,
      'matriculaAluno': matriculaAluno,
      'uidAluno': uidAluno,
      'disciplina': disciplina,
      'curso': curso,
      'titulo': titulo,
      'orientador': orientador,
      'uidOrientador': uidOrientador,
      'coOrientador': coOrientador,
      'uidCoorientador': uidCoorientador,
      'data': data,
      'horario': horario,
      'sala': sala,
      'membroDaBanca1': uidOrientador,
      'nomeMembroDaBanca1': orientador,
      'statusConvite1': 1,

      'membroDaBanca2': membroDaBanca2.uid,
      'nomeMembroDaBanca2': membroDaBanca2.nome,
      'statusConvite2': 0,

      'membroDaBanca3': membroDaBanca3.uid,
      'nomeMembroDaBanca3': membroDaBanca3.nome,
      'statusConvite3': membroDaBanca3.uid == null ? -1 : 0,

      'membroDaBanca4': membroDaBanca4.uid,
      'nomeMembroDaBanca4': membroDaBanca4.nome,
      'statusConvite4': membroDaBanca4.uid == null ? -1 : 0,

      'membroDaBanca5': membroDaBanca5.uid,
      'nomeMembroDaBanca5': membroDaBanca5.nome,
      'statusConvite5': membroDaBanca5.uid == null ? -1 : 0,
      'pendente': true,
      'excluido': false

      //-1 não existe o membro
      //0 ele não aceitou o convite
      //1 ele aceitou
      //2 ele recusou
    });
    await usuario
        .document(uidAluno)
        .updateData({'defesaPendente': result.documentID});

    await usuario
        .document(membroDaBanca2.uid)
        .collection("Convites")
        .document(result.documentID)
        .setData({
      'data': data,
      'horario': horario,
      'aluno': nomeAluno,
      'orientador': orientador
    });

    if (membroDaBanca3.uid != null)
      await usuario
          .document(membroDaBanca3.uid)
          .collection("Convites")
          .document(result.documentID)
          .setData({
        'data': data,
        'horario': horario,
        'aluno': nomeAluno,
        'orientador': orientador
      });

    if (membroDaBanca4.uid != null)
      await usuario
          .document(membroDaBanca4.uid)
          .collection("Convites")
          .document(result.documentID)
          .setData({
        'data': data,
        'horario': horario,
        'aluno': nomeAluno,
        'orientador': orientador
      });

    if (membroDaBanca5.uid != null)
      await usuario
          .document(membroDaBanca5.uid)
          .collection("Convites")
          .document(result.documentID)
          .setData({
        'data': data,
        'horario': horario,
        'aluno': nomeAluno,
        'orientador': orientador
      });
  }

  Future editarDefesa(Defesa d) async {
    await defesa.document(d.id).updateData({
      'nomeAluno': d.nomeAluno,
      'matriculaAluno': d.matriculaAluno,
      'uidAluno': d.uidAluno,
      'disciplina': d.disciplina,
      'curso': d.curso,
      'titulo': d.titulo,
      'orientador': d.orientador,
      'uidOrientador': d.uidOrientador,
      'coOrientador': d.coorientador,
      'uidCoorientador': d.uidCoorientador,
      'data': d.data,
      'horario': d.horario,
      'sala': d.local,
      'pendente': true,
      'excluido': false
    });

    //novos convites e retirar pedidos recusados
    DocumentSnapshot doc = await defesa.document(d.id).get();
    //recusados

    if (doc.data["statusConvite2"] == -2) {
      defesa.document(d.id).updateData({
        'membroDaBanca2': null,
        'nomeMembroDaBanca2': "",
        'statusConvite2': 0,
      });

      usuario
          .document(doc.data["membroDaBanca2"])
          .collection("Convites")
          .document(d.id)
          .delete();
    }

    if (doc.data["statusConvite3"] == -2) {
      defesa.document(d.id).updateData({
        'membroDaBanca3': null,
        'nomeMembroDaBanca3': "",
        'statusConvite3': 0,
      });

      usuario
          .document(doc.data["membroDaBanca3"])
          .collection("Convites")
          .document(d.id)
          .delete();
    }

    if (doc.data["statusConvite4"] == -2) {
      defesa.document(d.id).updateData({
        'membroDaBanca4': null,
        'nomeMembroDaBanca4': "",
        'statusConvite4': 0,
      });

      usuario
          .document(doc.data["membroDaBanca4"])
          .collection("Convites")
          .document(d.id)
          .delete();
    }

    if (doc.data["statusConvite5"] == -2) {
      defesa.document(d.id).updateData({
        'membroDaBanca5': null,
        'nomeMembroDaBanca5': "",
        'statusConvite5': 0,
      });

      usuario
          .document(doc.data["membroDaBanca5"])
          .collection("Convites")
          .document(d.id)
          .delete();
    }

    //novos

    if (d.membroDaBanca2 != doc.data["membroDaBanca2"] &&
        d.membroDaBanca2 != null) {
      usuario
          .document(doc.data["membroDaBanca2"])
          .collection("Convites")
          .document(d.id)
          .delete();

      await defesa.document(d.id).updateData({
        'membroDaBanca2': d.membroDaBanca3,
        'nomeMembroDaBanca2': d.nomeMembroDaBanca3,
        'statusConvite2': 0,
      });

      await usuario
          .document(d.membroDaBanca2)
          .collection("Convites")
          .document(d.id)
          .setData({
        'data': d.data,
        'horario': d.horario,
        'aluno': d.nomeAluno,
        'orientador': d.orientador
      });
    }

    if (d.membroDaBanca3 != doc.data["membroDaBanca3"] &&
        d.membroDaBanca3 != null) {
      usuario
          .document(doc.data["membroDaBanca3"])
          .collection("Convites")
          .document(d.id)
          .delete();

      await defesa.document(d.id).updateData({
        'membroDaBanca3': d.membroDaBanca3,
        'nomeMembroDaBanca3': d.nomeMembroDaBanca3,
        'statusConvite3': 0,
      });

      await usuario
          .document(d.membroDaBanca3)
          .collection("Convites")
          .document(d.id)
          .setData({
        'data': d.data,
        'horario': d.horario,
        'aluno': d.nomeAluno,
        'orientador': d.orientador
      });
    }

    if (d.membroDaBanca4 != doc.data["membroDaBanca4"] &&
        d.membroDaBanca4 != null) {
      usuario
          .document(doc.data["membroDaBanca4"])
          .collection("Convites")
          .document(d.id)
          .delete();

      await defesa.document(d.id).updateData({
        'membroDaBanca4': d.membroDaBanca4,
        'nomeMembroDaBanca4': d.nomeMembroDaBanca4,
        'statusConvite4': 0,
      });

      await usuario
          .document(d.membroDaBanca4)
          .collection("Convites")
          .document(d.id)
          .setData({
        'data': d.data,
        'horario': d.horario,
        'aluno': d.nomeAluno,
        'orientador': d.orientador
      });
    }

    if (d.membroDaBanca5 != doc.data["membroDaBanca5"] &&
        d.membroDaBanca5 != null) {
      usuario
          .document(doc.data["membroDaBanca5"])
          .collection("Convites")
          .document(d.id)
          .delete();

      await defesa.document(d.id).updateData({
        'membroDaBanca5': d.membroDaBanca5,
        'nomeMembroDaBanca5': d.nomeMembroDaBanca5,
        'statusConvite5': 0,
      });

      await usuario
          .document(d.membroDaBanca5)
          .collection("Convites")
          .document(d.id)
          .setData({
        'data': d.data,
        'horario': d.horario,
        'aluno': d.nomeAluno,
        'orientador': d.orientador
      });
    }
  }

  void aceitarPedidoDefesa(String idUser, String idDefesa) async {
    usuario.document(idUser).collection("Convites").document(idDefesa).delete();
    DocumentSnapshot doc = await defesa.document(idDefesa).get();
    if (idUser == doc.data["membroDaBanca2"]) {
      defesa.document(idDefesa).updateData({'statusConvite2': 1});
    } else if (idUser == doc.data["membroDaBanca3"]) {
      defesa.document(idDefesa).updateData({'statusConvite3': 1});
    } else if (idUser == doc.data["membroDaBanca4"]) {
      defesa.document(idDefesa).updateData({'statusConvite4': 1});
    } else if (idUser == doc.data["membroDaBanca5"]) {
      defesa.document(idDefesa).updateData({'statusConvite5': 1});
    }

    DocumentSnapshot doc2 = await defesa.document(idDefesa).get();
    if ((doc2.data["statusConvite2"] == 1 ||
            doc2.data["statusConvite2"] == -1) &&
        (doc2.data["statusConvite3"] == 1 ||
            doc2.data["statusConvite3"] == -1) &&
        (doc2.data["statusConvite4"] == 1 ||
            doc2.data["statusConvite4"] == -1) &&
        (doc2.data["statusConvite5"] == 1 ||
            doc2.data["statusConvite5"] == -1)) {
      defesa.document(idDefesa).updateData({'pendente': false});
    }
  }

  void recusarPedidoDefesa(String idUser, String idDefesa) async {
    usuario.document(idUser).collection("Convites").document(idDefesa).delete();
    DocumentSnapshot doc = await defesa.document(idDefesa).get();
    if (idUser == doc.data["membroDaBanca2"]) {
      defesa.document(idDefesa).updateData({'statusConvite2': 2});
    } else if (idUser == doc.data["membroDaBanca3"]) {
      defesa.document(idDefesa).updateData({'statusConvite3': 2});
    } else if (idUser == doc.data["membroDaBanca4"]) {
      defesa.document(idDefesa).updateData({'statusConvite4': 2});
    } else if (idUser == doc.data["membroDaBanca5"]) {
      defesa.document(idDefesa).updateData({'statusConvite5': 2});
    }
  }

  Future getProfessores() async {
    final result =
        await usuario.where('tipo', isEqualTo: "Professor").getDocuments();
    return result.documents.map((doc) {
      return new User(uid: doc.documentID, nome: doc.data['nome']);
    }).toList();
  }

  void atualizarDisciplina(String uid, String disciplina) {
    usuario.document(uid).updateData({'disciplina': disciplina});
  }

  void salvarTCC(String uidAluno, String nomeAluno, String titulo, String area,
      String url, String filename) async {
    var result =
        await tcc.where('uidAluno', isEqualTo: uidAluno).getDocuments();
    if (result.documents.length == 1) {
      // excluir documento antigo
      FirebaseStorage storage = FirebaseStorage.instance;
      StorageReference storageReference =
          await storage.getReferenceFromUrl(result.documents.first.data['url']);
      await storageReference.delete();
      tcc.document(result.documents.first.documentID).setData({
        'uidAluno': uidAluno,
        'aluno': nomeAluno,
        'titulo': titulo,
        'area': area,
        'url': url,
        'filename': filename
      });
    } else {
      tcc.document().setData({
        'uidAluno': uidAluno,
        'aluno': nomeAluno,
        'titulo': titulo,
        'area': area,
        'url': url,
        'filename': filename
      });
    }
  }

  void salvarHorario(
      String uid,
      List<Horario> listaSegunda,
      List<Horario> listaTerca,
      List<Horario> listaQuarta,
      List<Horario> listaQuinta,
      List<Horario> listaSexta,
      List<Horario> listaSabado) async {
    for (var item in listaSegunda) {
      usuario.document(uid).collection("Segunda").document(item.nome).setData({
        'horarioInicial': item.horarioInicial,
        'horarioFinal': item.horarioFinal,
        'possui': item.possui
      });
    }
    for (var item in listaTerca) {
      usuario.document(uid).collection("Terça").document(item.nome).setData({
        'horarioInicial': item.horarioInicial,
        'horarioFinal': item.horarioFinal,
        'possui': item.possui
      });
    }
    for (var item in listaQuarta) {
      usuario.document(uid).collection("Quarta").document(item.nome).setData({
        'horarioInicial': item.horarioInicial,
        'horarioFinal': item.horarioFinal,
        'possui': item.possui
      });
    }
    for (var item in listaQuinta) {
      usuario.document(uid).collection("Quinta").document(item.nome).setData({
        'horarioInicial': item.horarioInicial,
        'horarioFinal': item.horarioFinal,
        'possui': item.possui
      });
    }
    for (var item in listaSexta) {
      usuario.document(uid).collection("Sexta").document(item.nome).setData({
        'horarioInicial': item.horarioInicial,
        'horarioFinal': item.horarioFinal,
        'possui': item.possui
      });
    }
    for (var item in listaSabado) {
      usuario.document(uid).collection("Sabado").document(item.nome).setData({
        'horarioInicial': item.horarioInicial,
        'horarioFinal': item.horarioFinal,
        'possui': item.possui
      });
    }
  }

  Future getAulas(String diaDaSemana, String uid) async {
    var result = await usuario
        .document(uid)
        .collection(diaDaSemana)
        .where('possui', isEqualTo: true)
        .getDocuments();
    return result.documents;
  }

  Future<bool> temAula(String uid, String diaDaSemana, String horario) async {
    double horarioInicial;
    double horarioFinal;
    double horarioOrientacaoInicial;
    double horarioOrientacaoFinal;
    String hora;
    String minuto;

    var result = await usuario
        .document(uid)
        .collection(diaDaSemana)
        .where('possui', isEqualTo: true)
        .getDocuments();
    for (var aulas in result.documents) {
      hora = aulas.data["horarioInicial"].split(':')[0];
      minuto = aulas.data["horarioInicial"].split(':')[1];
      horarioInicial = double.parse(hora) + double.parse(minuto) / 60.0;
      hora = aulas.data["horarioFinal"].split(':')[0];
      minuto = aulas.data["horarioFinal"].split(':')[1];
      horarioFinal = double.parse(hora) + double.parse(minuto) / 60.0;
      horarioOrientacaoInicial =
          double.parse(horario.split("-")[0].split(":")[0]) +
              double.parse(horario.split("-")[0].split(":")[1]) / 60.0;
      horarioOrientacaoFinal =
          double.parse(horario.split("-")[1].split(":")[0]) +
              double.parse(horario.split("-")[1].split(":")[1]) / 60.0;
      if (((horarioInicial <= horarioOrientacaoFinal) &&
          (horarioFinal >= horarioOrientacaoInicial))) return true;
    }
    var horarioOrientacoes =
        await orientacoes.where('uidProfessor', isEqualTo: uid).getDocuments();
    for (var orientacao in horarioOrientacoes.documents) {
      if (diaDaSemana == orientacao.data['dia'] &&
          horario == orientacao.data['horario']) {
        return true;
      }
    }
    return false;
  }

  Future<bool> temOrientacao(String uid, String horario) async {
    double horarioAulaInicial;
    double horarioAulaFinal;
    double horarioOrientacaoInicial;
    double horarioOrientacaoFinal;
    String hora;
    String minuto;
    var horarioOrientacoes =
        await orientacoes.where('uidProfessor', isEqualTo: uid).getDocuments();
    for (var orientacao in horarioOrientacoes.documents) {
      hora = orientacao.data["horario"].split("-")[0].split(":")[0];
      minuto = orientacao.data["horario"].split("-")[0].split(":")[1];
      horarioOrientacaoInicial =
          double.parse(hora) + double.parse(minuto) / 60.0;
      hora = orientacao.data["horario"].split("-")[1].split(":")[0];
      minuto = orientacao.data["horario"].split("-")[1].split(":")[1];
      horarioOrientacaoFinal = double.parse(hora) + double.parse(minuto) / 60.0;
      horarioAulaInicial = double.parse(horario.split("-")[0].split(":")[0]) +
          double.parse(horario.split("-")[0].split(":")[1]) / 60.0;
      horarioAulaFinal = double.parse(horario.split("-")[1].split(":")[0]) +
          double.parse(horario.split("-")[1].split(":")[1]) / 60.0;
      if (((horarioAulaInicial <= horarioOrientacaoFinal) &&
          (horarioAulaFinal >= horarioOrientacaoInicial))) return true;
    }
    return false;
  }

  Future checarEmailCadastrado(String email) async {
    var result = await usuario.where('email', isEqualTo: email).getDocuments();
    if (result.documents.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future checarMatriculaCadastrada(String email) async {
    var result =
        await usuario.where('matricula', isEqualTo: email).getDocuments();
    if (result.documents.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> jaEnviouTCC(String uid) async {
    var result = await tcc.where('uidAluno', isEqualTo: uid).getDocuments();
    if (result.documents.length == 1) {
      return true;
    } else
      return false;
  }

  void deletarBaseDados() async {
    await defesa.getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    });
    await pedidoPendente.getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    });
    await orientacoes.getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    });
    await usuario.where('tipo',isEqualTo:'Professor').getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        usuario
            .document(ds.documentID)
            .collection('Convites')
            .getDocuments()
            .then((snapshot) {
          for (DocumentSnapshot ds in snapshot.documents) {
            ds.reference.delete();
          }
        });
      }
    });
    await usuario.where('tipo',isEqualTo:'Aluno').getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        usuario.document(ds.documentID).updateData({
          'defesaAgendada':"",
          'defesaPendente':"",
          'orientador':"",
          'pedidoPendente':false,
          'disciplina':""
        });
      }
    });
  }

  Future<int> qntOrientacao(String id,String dia) async{
    var result = await orientacoes.where('uidProfessor',isEqualTo: id).where('dia',isEqualTo:dia).getDocuments();
    int quantidadeDeOrientacoes = result.documents.length;
    return quantidadeDeOrientacoes;
  }

  Future<int> horasDeTrabalho(String id) async{
    int quantidadeAulas = 0;
    int quantidadeDeOrientacoes =0;
    var result = await usuario.document(id).collection("Segunda").where('possui',isEqualTo:true).getDocuments();
    quantidadeAulas += result.documents.length;
    result = await usuario.document(id).collection("Terça").where('possui',isEqualTo:true).getDocuments();
    quantidadeAulas += result.documents.length;
    result = await usuario.document(id).collection("Quarta").where('possui',isEqualTo:true).getDocuments();
    quantidadeAulas += result.documents.length;
    result = await usuario.document(id).collection("Quinta").where('possui',isEqualTo:true).getDocuments();
    quantidadeAulas += result.documents.length;
    result = await usuario.document(id).collection("Sexta").where('possui',isEqualTo:true).getDocuments();
    quantidadeAulas += result.documents.length;
    result = await usuario.document(id).collection("Sabado").where('possui',isEqualTo:true).getDocuments();
    quantidadeAulas += result.documents.length;


    result = await orientacoes.where('uidProfessor',isEqualTo: id).getDocuments();
    quantidadeDeOrientacoes = result.documents.length;
    return (quantidadeDeOrientacoes*45 + quantidadeAulas*90);
  }
}
