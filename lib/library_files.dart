import 'dart:io';
import 'dart:convert';

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
      String filePath = f.path;
      List<int> filePathBytes = utf8.encode(filePath);
      String filePathBase64 = base64Url.encode(filePathBytes);
      yield filePathBase64.replaceAll('=', '');
    }
  }

  @override
  Widget build(String id, BuildContext context) {
    return Image.file(File("bucegi-mountains-1641852.jpg"));
  }
}
