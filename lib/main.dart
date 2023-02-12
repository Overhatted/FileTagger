import 'package:file_tagger/library.dart';
import 'package:file_tagger/library_files.dart';
import 'package:flutter/material.dart';
import 'package:meilisearch/meilisearch.dart';
import 'package:dart_vlc/dart_vlc.dart';

void main() async {
  DartVLC.initialize();
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

class _SearchHit {
  final String id;
  final String description;

  _SearchHit(this.id, this.description);
}

class _MyHomePageState extends State<MyHomePage> {
  List<Library> _libraries = List.empty();
  String _currentSearchQuery = '';
  List<_SearchHit> _searchHits = List.empty();
  int _currentPage = 0;
  bool _isEditing = false;
  int _editingIndex = 0;

  _MyHomePageState() {
    _loadLibraries();
  }

  Future _loadLibraries() async {
    MeiliSearchClient client = MeiliSearchClient('http://127.0.0.1:7700');
    MeiliSearchIndex index = client.index('libraries');
    var documentsResult = await index.getDocuments();
    List<Library> newLibraries =
        List.from(documentsResult.results.map((result) {
      Map<String, dynamic> castedResult = result;
      //Get library factory from type
      Library newLibrary = LibraryFiles(castedResult);
      return newLibrary;
    }));
    _libraries = newLibraries;
    await _updateIndex();
    await _search('');
  }

  Future _updateIndex() async {
    List<Map<String, String>> documents = List.empty(growable: true);
    for (Library library in _libraries) {
      await for (final String id in library.getList()) {
        documents.add({
          'id': id,
          //TODO: Include library type
          'description': '',
        });
      }
    }
    MeiliSearchClient client = MeiliSearchClient('http://127.0.0.1:7700');
    MeiliSearchIndex index = client.index('objects');
    index.deleteAllDocuments();
    await index.addDocuments(documents);
  }

  Future _search(String query) async {
    _currentSearchQuery = query;
    await _updateSearchHits(0);
  }

  Future _updateSearchHits(int page) async {
    _currentPage = page;
    MeiliSearchClient client = MeiliSearchClient('http://127.0.0.1:7700');
    // An index is where the documents are stored.
    MeiliSearchIndex index = client.index('objects');
    // If the index 'movies' does not exist, Meilisearch creates it when you first add the documents.
    var result = await index.search(_currentSearchQuery, page: page);
    List<Map<String, dynamic>> hits = result.hits ?? List.empty();
    List<_SearchHit> hitsIds = List.from(hits.map((hit) {
      dynamic id = hit['id'];
      String castedId = id;
      dynamic description = hit['description'];
      String castedDescription = description;
      return _SearchHit(castedId, castedDescription);
    }));
    if (page == 0) {
      setState(() {
        _searchHits = hitsIds;
      });
    } else {
      setState(() {
        _searchHits.addAll(hitsIds);
      });
    }
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
        title: TextField(
          onChanged: (String value) {
            _search(value);
          },
        ),
      ),
      body: GridView.builder(
        addAutomaticKeepAlives: false,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        itemBuilder: (BuildContext context, int index) {
          if (_libraries.isNotEmpty) {
            Library library = _libraries.first;
            if (index < _searchHits.length) {
              return Column(
                children: [
                  Expanded(
                    child: library.build(_searchHits[index].id, context),
                  ),
                  _isEditing && _editingIndex == index
                      ? TextFormField(
                          initialValue: _searchHits[index].description,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                          textAlign: TextAlign.center,
                          onFieldSubmitted: (value) async {
                            MeiliSearchClient client =
                                MeiliSearchClient('http://127.0.0.1:7700');
                            MeiliSearchIndex objectsIndex =
                                client.index('objects');
                            String documentId = _searchHits[index].id;
                            await objectsIndex.updateDocuments([
                              {
                                'id': documentId,
                                //TODO: Include library type
                                'description': value,
                              }
                            ]);
                            //The if statement is in case the _searchHits changes while the documents are being updated:
                            if (index < _searchHits.length &&
                                documentId == _searchHits[index].id) {
                              _searchHits[index] =
                                  _SearchHit(_searchHits[index].id, value);
                            }
                            setState(() {
                              _isEditing = false;
                            });
                          },
                        )
                      : GestureDetector(
                          child: Text(
                            _searchHits[index].description.isEmpty
                                ? "Click to add description"
                                : _searchHits[index].description,
                          ),
                          onTap: () {
                            setState(() {
                              _isEditing = true;
                              _editingIndex = index;
                            });
                          },
                        ),
                ],
              );
            } else {
              _updateSearchHits(++_currentPage);
              return null;
            }
          } else {
            return null;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _search('Action'),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
