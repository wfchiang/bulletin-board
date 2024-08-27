import 'dart:developer';
import 'dart:convert';

import 'package:yaml/yaml.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
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
          String indexJsonUrl = yamlMap['indexJsonUrl'];

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
            home: BulletinBoard(indexJsonUrl: indexJsonUrl),
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
  const BulletinBoard({super.key, required this.indexJsonUrl});

  final String indexJsonUrl;

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<BulletinBoard> createState() => _BulletinBoardState(this.indexJsonUrl);
}

class _BulletinBoardState extends State<BulletinBoard> {
  _BulletinBoardState(this.indexJsonUrl);

  final String indexJsonUrl;
  int _currentId = 0;
  Map<String, dynamic>? _index;
  Map<String, Image> _flyerCache = Map();

  // State initialization
  Future<void> _fetchIndex () async {
    final response = await http.get(Uri.parse(this.indexJsonUrl));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      rootLogger.i('Acquired index: ' + jsonData.toString());
      setState(() {
        this._index = jsonData;
      });
    } else {
      throw Exception('Failed to load index...');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchIndex();
  }

  // Function for increasing flyer index
  void _increaseCurrentId() {
    int newCurrentId = (
        this._index == null || this._currentId >= (this._index!["flyers"].length - 1)
            ? 0
            : this._currentId + 1
    );
    setState(() {
      this._currentId = newCurrentId;
    });
  }

  // Widget building/rendering function
  @override
  Widget build(BuildContext context) {
    if (this._index == null) {
      return const CircularProgressIndicator();
    }
    else if (this._index!.length == 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text('No Flyer'),
        ),
        body: Center(
          child: Image(
            image: AssetImage('assets/no_flyer.png'),
          ),
        ),
      );
    }
    else {
      int flyerId = (
          this._currentId >= this._index!['flyers'].length
          ? 0
          : this._currentId
      );

      List<dynamic> flyerInfoList = this._index!['flyers'];
      Map<String, dynamic> flyerInfo = flyerInfoList[flyerId];
      String flyerTitle = flyerInfo['title']!;
      String flyerUrl = flyerInfo['url']!;

      Image? flyerImage = null;
      if (this._flyerCache.containsKey((flyerUrl))) {
        flyerImage = this._flyerCache[flyerUrl];
      }
      else {
        flyerImage = Image.network(
          flyerUrl,
          fit: BoxFit.cover, // Adjust the fit as needed
        );
        this._flyerCache[flyerUrl] = flyerImage;
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(flyerTitle),
        ),
        body: flyerImage,
        floatingActionButton: FloatingActionButton(
          onPressed: _increaseCurrentId,
          tooltip: 'Next Flyer',
          child: const Icon(Icons.arrow_right),
        ),
      );
    }
  }
}
