import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

var textInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    border: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(25.0),
        borderSide: BorderSide()));

const textStyle = TextStyle(fontSize: 18, color: Colors.black);

const textStyle2 = TextStyle(fontSize: 18, color: Colors.white);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();