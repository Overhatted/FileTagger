import 'package:file_tagger/library.dart';
import 'package:file_tagger/library_files.dart';
import 'package:file_tagger/tagged_image_file.dart';
import 'package:file_tagger/tagged_object.dart';
import 'package:flutter/material.dart';
import 'package:meilisearch/meilisearch.dart';
import 'package:meilisearch/src/result.dart';

void main() async {
  MeiliSearchClient client = MeiliSearchClient('http://127.0.0.1:7700');

  // An index is where the documents are stored.
  MeiliSearchIndex index = client.index('movies');

  const documents = [
    {
      'id': 1,
      'title': 'Carol',
      'genres': ['Romance', 'Drama']
    },
    {
      'id': 2,
      'title': 'Wonder Woman',
      'genres': ['Action', 'Adventure']
    },
    {
      'id': 3,
      'title': 'Life of Pi',
      'genres': ['Adventure', 'Drama']
    },
    {
      'id': 4,
      'title': 'Mad Max: Fury Road',
      'genres': ['Adventure', 'Science Fiction']
    },
    {
      'id': 5,
      'title': 'Moana',
      'genres': ['Fantasy', 'Action']
    },
    {
      'id': 6,
      'title': 'Philadelphia',
      'genres': ['Drama']
    },
  ];

  // If the index 'movies' does not exist, Meilisearch creates it when you first add the documents.
  await index.addDocuments(documents); // => { "uid": 0 }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<Library> _libraries = List.empty();
  List<TaggedObject> _taggedObjects = List.empty(growable: true);

  _MyHomePageState() {
    _loadLibraries();
  }

  void _loadLibraries() async {
    MeiliSearchClient client = MeiliSearchClient('http://127.0.0.1:7700');
    MeiliSearchIndex index = client.index('libraries');
    Result documentsResult = await index.getDocuments();
    List<Library> newLibraries =
        List.from(documentsResult.results.map((result) {
      Map<String, dynamic> castedResult = result;
      //Get library factory from type
      Library newLibrary = LibraryFiles(castedResult);
      return newLibrary;
    }));
    setState(() {
      _libraries = newLibraries;
    });
  }

  void _incrementCounter() async {
    MeiliSearchClient client = MeiliSearchClient('http://127.0.0.1:7700');
    // An index is where the documents are stored.
    MeiliSearchIndex index = client.index('movies');
    // If the index 'movies' does not exist, Meilisearch creates it when you first add the documents.
    var result = await index.search('carlo');
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      if (result.hits == null) {
        _taggedObjects.add(TaggedImageFile());
      }
      _taggedObjects.add(TaggedImageFile());
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        itemBuilder: (BuildContext context, int index) {
          if (index < _taggedObjects.length) {
            return _taggedObjects[index].build(context);
          } else {
            return null;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
