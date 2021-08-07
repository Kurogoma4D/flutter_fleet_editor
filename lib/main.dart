import 'dart:ui';

import 'package:come_back_fleet/download.dart';
import 'package:come_back_fleet/overlay_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final _repaint = GlobalKey();

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
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final colors = [
    LinearGradient(
      colors: [
        Color.fromRGBO(1, 137, 181, 1),
        Color.fromRGBO(80, 80, 245, 1),
        Color.fromRGBO(50, 236, 220, 1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [
        Color.fromRGBO(34, 193, 195, 1),
        Color.fromRGBO(253, 187, 45, 1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
  ];

  int colorIndex = 0;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              key: _repaint,
              child: Navigator(
                onGenerateRoute: (settings) => MaterialPageRoute(
                  builder: (context) => Canvas(
                    colorIndex: colorIndex,
                    colors: colors,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(80),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                children: [
                  for (final color in colors) ...[
                    GestureDetector(
                      onTap: () => setState(() {
                        colorIndex = colors.indexOf(color);
                      }),
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          gradient: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black54, width: 1),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
          if (isProcessing)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.download),
        onPressed: () async {
          setState(() {
            isProcessing = true;
          });

          final boundary = _repaint.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
          final image = await boundary.toImage();

          final byteData = await image.toByteData(format: ImageByteFormat.png);
          final binary = byteData!.buffer.asUint8List();

          download(binary);

          setState(() {
            isProcessing = false;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    for (final e in overlays) {
      e.data.controller.dispose();
      e.data.focus.dispose();
    }

    super.dispose();
  }
}

class Canvas extends StatelessWidget {
  const Canvas({
    Key? key,
    required this.colors,
    required this.colorIndex,
  }) : super(key: key);

  final List<Gradient> colors;
  final int colorIndex;

  void addElement(BuildContext context) {
    final element = ElementData()
      ..position = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      )
      ..isEditMode = true
      ..focus.requestFocus();
    overlays.add(OverlayData.create(element));

    Navigator.of(context).overlay?.insert(overlays.last.overlay);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => addElement(context),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: colors[colorIndex]),
      ),
    );
  }
}
