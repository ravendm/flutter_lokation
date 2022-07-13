import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:lokation/lokation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<LatLng>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _locationSubscription = Lokation.locationStream.listen(_locationListener);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    super.dispose();
  }

  void _locationListener(LatLng event) {
    debugPrint('$event');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await Permission.location.request();
                await Lokation.startPositionUpdates();
              },
              child: Text('START'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Lokation.stopPositionUpdates();
              },
              child: Text('STOP'),
            ),
          ],
        ),
      ),
    );
  }
}
