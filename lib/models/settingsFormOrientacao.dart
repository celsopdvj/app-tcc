import 'package:app_tcc/models/user.dart';

class ScreenArguments {
  final User professor;
  final User aluno;
  final String pedidoUid;

  ScreenArguments({this.professor, this.aluno, this.pedidoUid});
}