import 'package:app_tcc/models/user.dart';
import 'package:app_tcc/services/auth.dart';
import 'package:app_tcc/services/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Future onSelectNotification(String payload){
      debugPrint("payload: $payload");
    }

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
      initializationSettingsAndroid,
      initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );

    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [const Locale('pt', 'BR')],
        onGenerateRoute: Router.generateRoute,
        initialRoute: '/',
      ),
    );
  }
}

