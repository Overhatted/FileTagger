import 'dart:io';

import 'package:file_tagger/tagged_object.dart';
import 'package:flutter/widgets.dart';

class TaggedImageFile implements TaggedObject {
  @override
  List<String> getTags() {
    return ["landscape", "grass"];
  }

  @override
  Widget build(BuildContext context) {
    return Image.file(File("bucegi-mountains-1641852.jpg"));
  }
}
