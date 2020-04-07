import 'package:app_tcc/models/settingsFormDefesa.dart';
import 'package:app_tcc/models/settingsFormOrientacao.dart';
import 'package:app_tcc/models/settingsTCC.dart';
import 'package:app_tcc/screens/aluno/enviarOrientacao.dart';
import 'package:app_tcc/screens/aluno/exibirTCC.dart';
import 'package:app_tcc/screens/aluno/visualizarTCC.dart';
import 'package:app_tcc/screens/authenticate/digitarEmail.dart';
import 'package:app_tcc/screens/authenticate/register.dart';
import 'package:app_tcc/screens/authenticate/registerProfessor.dart';
import 'package:app_tcc/screens/authenticate/sign_in.dart';
import 'package:app_tcc/screens/authenticate/tipoUsuario.dart';
import 'package:app_tcc/screens/coordenacao/exibirOrientacoes.dart';
import 'package:app_tcc/screens/coordenacao/novoValidarPedidoOrientacao.dart';
import 'package:app_tcc/screens/coordenacao/validarPedidoOrientacao.dart';
import 'package:app_tcc/screens/geral/exibirDefesas.dart';
import 'package:app_tcc/screens/home/home.dart';
import 'package:app_tcc/screens/home/homeCoordenacao.dart';
import 'package:app_tcc/screens/home/homeProfessor.dart';
import 'package:app_tcc/screens/professor/agendarDefesa.dart';
import 'package:app_tcc/screens/professor/convitesDefesa.dart';
import 'package:app_tcc/screens/professor/defesasAgendadas.dart';
import 'package:app_tcc/screens/professor/editarDefesa.dart';
import 'package:app_tcc/screens/professor/enviarTCC.dart';
import 'package:app_tcc/screens/professor/formularioDeDefesa.dart';
import 'package:app_tcc/screens/professor/formularioEnviarTCC.dart';
import 'package:app_tcc/screens/professor/formularioOrientacao.dart';
import 'package:app_tcc/screens/professor/gerarAtaDefesa.dart';
import 'package:app_tcc/screens/professor/horarios.dart';
import 'package:app_tcc/screens/professor/pedidosDeOrientacao.dart';
import 'package:flutter/material.dart';


class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {

    Object args;
    ScreenArguments args2;
    ScreenArgumentsTCC args3;
    ScreenArgumentsDefesa args4;
    if(settings.name == '/formularioOrientacao' || settings.name == '/formularioDeDefesa' || settings.name == '/formularioEnviarTCC')
      args2 = settings.arguments;
    else if(settings.name == '/visualizarTCC')
      args3 = settings.arguments;
    else if(settings.name == '/editarDefesa')
      args4 = settings.arguments;
    else
      args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SignIn());
      case '/tipoUsuario':
        return MaterialPageRoute(builder: (_) => TipoUsuario());
      case '/resetarSenha':
        return MaterialPageRoute(builder: (_) => DigitarEmail());
      case '/registroAluno':
        return MaterialPageRoute(builder: (_) => Register());
      case '/registroProfessor':
        return MaterialPageRoute(builder: (_) => RegisterProfessor());
      case '/horarios':
        return MaterialPageRoute(builder: (_) => Horarios(user: args));
      case '/home':
        return MaterialPageRoute(builder: (_) => Home(user: args));
      case '/homeCoordenacao':
        return MaterialPageRoute(builder: (_) => HomeCoordenacao(user: args));
      case '/homeProfessor':
        return MaterialPageRoute(builder: (_) => HomeProfessor(user: args));
      case '/enviarOrientacao':
        return MaterialPageRoute(builder: (_) => EnviarOrientacao(user: args));
      case '/validarPedidoOrientacao':
        return MaterialPageRoute(builder: (_) => ValidarOrientacao(user: args));
      case '/novoValidarPedidoOrientacao':
        return MaterialPageRoute(builder: (_) => NovoValidarPedido());
      case '/pedidosDeOrientacao':
        return MaterialPageRoute(builder: (_) => PedidosDeOrientacao(user: args));
      case '/formularioOrientacao':
        return MaterialPageRoute(builder: (_) => FormularioOrientacao(user: args2.professor, aluno: args2.aluno, pedidoUid: args2.pedidoUid,));
      case '/exibirOrientacoes':
        return MaterialPageRoute(builder: (_) => ExibirOrientacoes());
      case '/exibirDefesas':
        return MaterialPageRoute(builder: (_) => ExibirDefesas());
      case '/defesasAgendadas':
        return MaterialPageRoute(builder: (_) => DefesasAgendadas(user: args));
      case '/agendarDefesa':
        return MaterialPageRoute(builder: (_) => AgendarDefesa(user: args));
      case '/convitesDefesa':
        return MaterialPageRoute(builder: (_) => ConvitesDefesa(user: args));
      case '/formularioDeDefesa':
        return MaterialPageRoute(builder: (_) => FormularioDeDefesa(user: args2.professor, aluno: args2.aluno,));
      case '/editarDefesa':
        return MaterialPageRoute(builder: (_) => EditarDefesa(user: args4.user, defesa: args4.defesa,));
      case '/enviarTCC':
        return MaterialPageRoute(builder: (_) => EnviarTCC(user: args));
      case '/formularioEnviarTCC':
        return MaterialPageRoute(builder: (_) => FormularioDeEnvioTCC(user: args2.professor, aluno: args2.aluno,));
      case '/exibirTCC':
        return MaterialPageRoute(builder: (_) => ExibirTCC(user: args));
      case '/gerarAtaDefesa':
        return MaterialPageRoute(builder: (_) => GerarAtaDefesa(user: args));
      case '/visualizarTCC':
        return MaterialPageRoute(builder: (_) => VisualizarTCC(url: args3.url, filename: args3.filename));
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}