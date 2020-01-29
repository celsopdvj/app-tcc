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
      'validado' : false,
      'excluido' : 0
    });
  }

  Future<bool> getPedidoPendente(String uid) async{
    final result = await usuario.document(uid).get();
    return result.data['pedidoPendente'];
  }

  void deletaPedidoPendenteDoAluno (String uidAluno) async{
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

  Future getUser (String uid) async{
    final result = await usuario.document(uid).get();
    return new User(uid: uid ,curso: result.data['curso'], matricula: result.data['matricula'], nome: result.data['nome']);
  }

  Future getTurma() async{
    final snapShot = await orientacao.document('turmas').get();
    await orientacao.document('turmas').updateData({'contador': FieldValue.increment(1)});
    int contador =  snapShot.data['contador'];
    return contador;
  }

  void salvarOrientacao(String curso, String disciplina, String turma, String dia, String horario
                          , String nomeProfessor, String matriculaAluno, String nomeAluno, String obs, String uidAluno, String uidProfessor) async{
    await orientacoes.document().setData({
      'curso': curso,
      'disciplina': disciplina,
      'turma': turma,
      'dia': dia,
      'horario': horario,
      'nomeProfessor': nomeProfessor,
      'matricula': matriculaAluno,
      'nomeAluno': nomeAluno,
      'observacoes':obs,
      'uidAluno': uidAluno,
      'uidProfessor': uidProfessor
    });
    usuario.document(uidAluno).updateData({
      'orientador': nomeProfessor
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
}
