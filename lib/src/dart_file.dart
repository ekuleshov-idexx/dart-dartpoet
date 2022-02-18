import 'dart:io';

import 'package:dartpoet/dartpoet.dart';

class DartFile {
  final FileSpec fileSpec;

  String get _content => format(fileSpec.code(args: {KEY_REVERSE_CLASSES: true}));

  DartFile.empty() : fileSpec = FileSpec.build();

  DartFile.fromFileSpec(this.fileSpec);

  String outputContent() => _content;

  // Future<File> outputFileAsync(String path) => XFile.fromPath(path).file.writeAsString(outputContent());
  Future<File> outputFileAsync(String path) async {
    final file = File(path);
    return file.writeAsString(outputContent());
  }

  // File outputSync(String path) => XFile.fromPath(path).file..writeAsStringSync(outputContent());
  File outputSync(String path) => File(path)..writeAsStringSync(outputContent());
}
