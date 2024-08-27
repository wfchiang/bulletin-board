import 'dart:developer';

import 'package:yaml/yaml.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/*
The main entrance
 */
void main() {
  runApp(const MyApp());
}


/*
Logger
 */
final rootLogger = Logger();


/*
Helper function(s)
 */
// Load yaml file
Future<YamlMap> loadYamlFile() async {
  final String yamlString = await rootBundle.loadString('assets/app_config.yaml');
  final YamlMap yamlMap = loadYaml(yamlString);
  return yamlMap;
}


/*
Classes
 */
// The main app class
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<YamlMap>(
      future: loadYamlFile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          String errorMessage = snapshot.error.toString();
          rootLogger.e(errorMessage);
          return MaterialApp(
            title: 'Error',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
              useMaterial3: true,
            ),
            home: ErrorPage(errorMessage: errorMessage),
          );
        } else {
          final YamlMap yamlMap = snapshot.data!;
          String appTitle = yamlMap['appTitle'];

          return MaterialApp(
            title: appTitle,
            theme: ThemeData(
              // This is the theme of your application.
              //
              // TRY THIS: Try running your application with "flutter run". You'll see
              // the application has a purple toolbar. Then, without quitting the app,
              // try changing the seedColor in the colorScheme below to Colors.green
              // and then invoke "hot reload" (save your changes or press the "hot
              // reload" button in a Flutter-supported IDE, or press "r" if you used
              // the command line to start the app).
              //
              // Notice that the counter didn't reset back to zero; the application
              // state is not lost during the reload. To reset the state, use hot
              // restart instead.
              //
              // This works for code too, not just values: Most code changes can be
              // tested with just a hot reload.
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
              useMaterial3: true,
            ),
            home: BulletinBoard(),
            // home: const BulletinBoard(
            //   title: 'This is a test'
            // ),
          );
        }
      },
    );
  }
}


// The error page class
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, required this.errorMessage});
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(this.errorMessage),
        ),
        backgroundColor: Colors.pink[50],
        body: Center(
          child: Image(
            image: AssetImage('assets/error_sorry.png'),
          ),
        ),
    );
  }
}

// The bulletin board class
class BulletinBoard extends StatefulWidget {
  const BulletinBoard({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<BulletinBoard> createState() => _BulletinBoardState();
}

class _BulletinBoardState extends State<BulletinBoard> {
  int _flyerIndex = 0;


  void _increaseIndex() {
    // setState(() {
    //   _counter++;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('No Flyer'),
      ),
      body: Center(
        child: Image(
          image: AssetImage('assets/no_flyer.png'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increaseIndex,
        tooltip: 'Next Flyer',
        child: const Icon(Icons.arrow_right),
      ),
    );
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    // return Scaffold(
    //   appBar: AppBar(
    //     // TRY THIS: Try changing the color here to a specific color (to
    //     // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
    //     // change color while the other colors stay the same.
    //     backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    //     // Here we take the value from the MyHomePage object that was created by
    //     // the App.build method, and use it to set our appbar title.
    //     title: Text(widget.title),
    //   ),
    //   body: Center(
    //     // Center is a layout widget. It takes a single child and positions it
    //     // in the middle of the parent.
    //     child: Column(
    //       // Column is also a layout widget. It takes a list of children and
    //       // arranges them vertically. By default, it sizes itself to fit its
    //       // children horizontally, and tries to be as tall as its parent.
    //       //
    //       // Column has various properties to control how it sizes itself and
    //       // how it positions its children. Here we use mainAxisAlignment to
    //       // center the children vertically; the main axis here is the vertical
    //       // axis because Columns are vertical (the cross axis would be
    //       // horizontal).
    //       //
    //       // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
    //       // action in the IDE, or press "p" in the console), to see the
    //       // wireframe for each widget.
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         const Text(
    //           'You have pushed the button this many times:',
    //         ),
    //         Text(
    //           '$_counter',
    //           style: Theme.of(context).textTheme.headlineMedium,
    //         ),
    //       ],
    //     ),
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: _incrementCounter,
    //     tooltip: 'Next Flyer',
    //     child: const Icon(Icons.arrow_right),
    //   ), // This trailing comma makes auto-formatting nicer for build methods.
    // );
  }
}
