import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});
  // collection reference
  final CollectionReference usuario = Firestore.instance.collection('usuario');
  final CollectionReference pedidoPendente = Firestore.instance.collection('pedidoPendente');

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
        'pedidoPendente': pedidoPendente
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

  Future updatePedidoPendente(String uidAluno, String uidOrientador, String nomeAluno, String nomeProfessor) async{
    await usuario.document(uidAluno).updateData({
      'pedidoPendente': true
    });
    return await pedidoPendente.document().setData({
      'uidAluno' : uidAluno,
      'uidProfessor': uidOrientador,
      'nomeAluno': nomeAluno,
      'nomeProfessor': nomeProfessor,
      'validado' : false
    });
  }

  Future<bool> getPedidoPendente(String uid) async{
    final result = await usuario.document(uid).get();
    return result.data['pedidoPendente'];
  }

  void deletaPedidoPendente (String uidAluno) async{
    try{
      final aux = await pedidoPendente.where("uidAluno", isEqualTo: uidAluno).getDocuments();
      final x = aux.documents.first;
      await pedidoPendente.document(x.documentID).delete();
      await usuario.document(uidAluno).updateData({
        'pedidoPendente': false
      });
    }
    catch(e){
      print(e);
    }
  }

  void validaPedidoPendente(String uidDoc) async{
    await pedidoPendente.document(uidDoc).updateData({
      'validado' : true
    });
  }
}
