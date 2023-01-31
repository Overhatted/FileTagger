import 'package:flutter/material.dart';

abstract class TaggedObject {
  List<String> getTags();
  Widget build(BuildContext context);
}
