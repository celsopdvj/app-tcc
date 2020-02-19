import 'package:app_tcc/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});
  // collection reference
  final CollectionReference usuario = Firestore.instance.collection('usuario');
  final CollectionReference pedidoPendente = Firestore.instance.collection('pedidoPendente');
  final CollectionReference orientacao = Firestore.instance.collection('orientacao');
  final CollectionReference orientacoes = Firestore.instance.collection('orientacao/turmas/orientacoes');
  final CollectionReference defesa = Firestore.instance.collection('defesa');

  Future updateUserData(String matricula, String senha, String nome,
      String email, String curso, String telefone, String tipoUsuario, String areaAtuacao, bool pedidoPendente) async {
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
        'disciplina' : 'CMP1071'
      });
    }
    else{
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

  Future updatePedidoPendente(String uidAluno, String uidOrientador, String nomeAluno, String nomeProfessor, String disciplina) async{
     await pedidoPendente.document().setData({
      'uidAluno' : uidAluno,
      'uidProfessor': uidOrientador,
      'nomeAluno': nomeAluno,
      'nomeProfessor': nomeProfessor,
      'validado' : false,
      'excluido' : 0,
      'disciplina': disciplina
    });
    return await usuario.document(uidAluno).updateData({
      'pedidoPendente': true
    });
  }

  void desabilitaPedidoPendente(String uid) async {
     usuario.document(uid).updateData({
      'pedidoPendente': true
    });
  }

  Future<bool> getPedidoPendente(String uid) async{
    final result = await usuario.document(uid).get();
    return result.data['pedidoPendente'];
  }

  Future<bool> deletaPedidoPendenteDoAluno(String uidAluno) async{
    try{
      final aux = await pedidoPendente.where("uidAluno", isEqualTo: uidAluno).getDocuments();
      final x = aux.documents.first;
      await pedidoPendente.document(x.documentID).delete();
      await usuario.document(uidAluno).updateData({
        'pedidoPendente': false
      });
      return true;
    }
    catch(e){
      print(e);
      return false;
    }
  }

  void validaPedidoPendente(String uidDoc) async{
    await pedidoPendente.document(uidDoc).updateData({
      'validado' : true
    });
  }

  Future getUser (String uid) async{
    final result = await usuario.document(uid).get();
    return new User(uid: uid ,curso: result.data['curso'], matricula: result.data['matricula'],
     nome: result.data['nome'], email: result.data['email'], disciplina: result.data['disciplina']);
  }

  Future getTurma(String curso) async{
    final snapShot = await orientacao.document('turmas').get();
    if(curso == 'Engenharia de Computação' || curso == 'Ciência de Computação'){
      await orientacao.document('turmas').updateData({'contadorA': FieldValue.increment(1)});
      return "A" + snapShot.data['contadorA'].toString().padLeft(2,'0');
    }
    else{
      await orientacao.document('turmas').updateData({'contadorC': FieldValue.increment(1)});
      return "C" + snapShot.data['contadorC'].toString().padLeft(2,'0');
    }
  }

  void salvarOrientacao(String curso, String disciplina, String turma, String dia, String horario
                          , String nomeProfessor, String matriculaAluno, String nomeAluno, String uidAluno, String uidProfessor) async{
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
    usuario.document(uidAluno).updateData({
      'orientador': uidProfessor
    });
  }

  void deletarPedido(String pedidoUid) async{
    final result = await pedidoPendente.document(pedidoUid).get();
    this.usuario.document(result.data['uidAluno']).updateData({
      'pedidoPendente': false
    });
    await pedidoPendente.document(pedidoUid).delete();
  }

  Future getOrientador(String uid) async{
    final result = await usuario.document(uid).get();
    return result.data['orientador'];
  }

  Future getOrientacoes() async{
    final result = await orientacoes.getDocuments();  
    return result.documents;
  }

  Future getDefesas() async{
    final result = await defesa.getDocuments();  
    return result.documents;
  }

  Future salvarDefesa(String nomeAluno, String matriculaAluno, String uidAluno, String disciplina, String curso, String titulo, 
                    String orientador, String uidOrientador, String coOrientador, String uidCoorientador, String data, String horario, 
                    String sala, String membroDaBanca1, String membroDaBanca2, String membroDaBanca3, String membroDaBanca4, String membroDaBanca5) async{
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
      'membroDaBanca1': membroDaBanca1,
      'membroDaBanca2': membroDaBanca2,
      'membroDaBanca3': membroDaBanca3,
      'membroDaBanca4': membroDaBanca4,
      'membroDaBanca5': membroDaBanca5,
      'excluido': false
    });
    await usuario.document(uidAluno).updateData({
      'defesaAgendada': result.documentID
    });
  }

  Future getProfessores()async{
    final result = await usuario.where('tipo', isEqualTo:"Professor").getDocuments();
    return result.documents.map((doc){
      return new User(uid: doc.documentID, nome: doc.data['nome']);
    }).toList();
  }
}
