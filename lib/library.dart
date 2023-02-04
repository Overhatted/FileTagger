import 'package:flutter/material.dart';

abstract class Library {
  Stream<String> getList();
  Widget build(String id, BuildContext context);
}
