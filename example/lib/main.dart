import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:open_image_picker/open_image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Uint8List> _bytes = [];

  void _incrementCounter() {
    openImage().then((value) {
      if (value.isNotEmpty) {
        Future.wait(value.map((e) {
          return e.readImage(context, maxWidth: 200, maxHeight: 200).then((value) {
            return value.toByteData(format: ImageByteFormat.png);
          }).then((value) => value.buffer.asUint8List());
        })).then((value) {
          setState(() {
            _bytes = value;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OpenImage"),
      ),
      body: ListView.builder(
        itemCount: _bytes.length,
        itemBuilder: (context, index) {
          return SizedBox(
            child: Image.memory(_bytes[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
