import 'dart:io';
import 'dart:convert';

import 'package:file_tagger/library.dart';
import 'package:flutter/widgets.dart';

class LibraryFiles implements Library {
  final String _folder;

  /// From: https://stackoverflow.com/a/9194117/1631656
  int _roundUpToNearestMultipleOf4(int numToRound) {
    return ((numToRound + 4 - 1) ~/ 4) * 4;
  }

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
    int desiredLength = _roundUpToNearestMultipleOf4(id.length);
    String paddedId = id.padRight(desiredLength, '=');
    List<int> filePathBytes = base64Url.decode(paddedId);
    String filePath = utf8.decode(filePathBytes);
    return Image.file(File("bucegi-mountains-1641852.jpg"));
  }
}
