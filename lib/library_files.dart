import 'dart:io';

import 'package:file_tagger/library.dart';
import 'package:flutter/widgets.dart';

class LibraryFiles implements Library {
  final String _folder;

  LibraryFiles(Map<String, dynamic> parameters)
      : _folder = parameters["folder"];

  @override
  Stream<String> getList() async* {
    var dir = Directory(_folder);

    Stream<FileSystemEntity> dirList = dir.list();
    await for (final FileSystemEntity f in dirList) {
      yield f.path;
    }
  }

  @override
  Widget build(String id, BuildContext context) {
    return Image.file(File("bucegi-mountains-1641852.jpg"));
  }
}
