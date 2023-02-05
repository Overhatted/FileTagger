import 'dart:io';
import 'dart:convert';

import 'package:file_tagger/library.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';

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
    Directory directory = Directory(_folder);
    Stream<FileSystemEntity> directorySubEntities =
        directory.list(recursive: true, followLinks: false);
    await for (FileSystemEntity entity in directorySubEntities) {
      if (entity is File) {
        String filePath = relative(entity.path, from: _folder);
        List<int> filePathBytes = utf8.encode(filePath);
        String filePathBase64 = base64Url.encode(filePathBytes);
        int numberOfEqualsSigns = 0;
        for (int i = filePathBase64.length; i-- > 0;) {
          if (filePathBase64[i] == '=') {
            ++numberOfEqualsSigns;
          } else {
            break;
          }
        }
        yield filePathBase64.substring(
            0, filePathBase64.length - numberOfEqualsSigns);
      }
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
