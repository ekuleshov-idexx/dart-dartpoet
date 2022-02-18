import 'package:dartpoet/dartpoet.dart';

class MethodSpec implements Spec {
  final DocSpec? doc;
  final String methodName;
  final List<MetaSpec> metas;
  final List<ParameterSpec> parameters;
  final TypeToken? returnType;
  final CodeBlockSpec? codeBlock;
  final bool isStatic;
  final bool isFactory;
  final bool isAbstract;
  final List<TypeToken> generics;
  final AsynchronousMode asynchronousMode;

  bool get hasGeneric => generics.isNotEmpty;

  MethodSpec.build(
    this.methodName, {
    this.doc,
    List<MetaSpec>? metas,
    List<ParameterSpec>? parameters,
    this.returnType,
    this.codeBlock,
    this.isStatic = false,
    this.isFactory = false,
    this.isAbstract = false,
    this.asynchronousMode = AsynchronousMode.none,
    List<TypeToken>? generics,
  })
      : this.metas = metas ?? [],
        this.parameters = parameters ?? [],
        this.generics = generics ?? [];

  @override
  String code({Map<String, dynamic> args = const {}}) {
    String raw = '';
    var elements = [];
    if (isFactory) elements.add('factory');
    if (isStatic) elements.add('static');
    if (returnType != null) elements.add(returnType!.fullTypeName);
    elements.add(methodName);
    if (hasGeneric) elements.add('<${generics.join(", ")}>');
    raw += elements.join(' ');
    raw += '(${collectParameters(parameters)})';
    if (isAbstract) {
      raw += ';';
    } else {
      switch (asynchronousMode) {
        case AsynchronousMode.none:
          break;
        case AsynchronousMode.asyncFuture:
          raw += ' async';
          break;
        case AsynchronousMode.asyncStream:
          raw += ' async*';
          break;
        case AsynchronousMode.syncIterable:
          raw += ' sync*';
          break;
      }
      raw += ' ' + collectCodeBlock(codeBlock, withLambda: true);
    }
    raw = collectWithMeta(metas, raw);
    raw = collectWithDoc(doc, raw);
    return raw;
  }
}

String collectMethods(List<MethodSpec> methods) {
  return methods.map((o) => o.code()).join('\n\n');
}

enum AsynchronousMode {
  none,
  asyncFuture,
  asyncStream,
  syncIterable,
}
