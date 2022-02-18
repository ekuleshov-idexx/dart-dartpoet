import 'package:dartpoet/dartpoet.dart';

class ClassSpec implements Spec {
  final DocSpec? doc;

  final List<MetaSpec> metas;

  final List<GetterSpec> getters;

  final List<SetterSpec> setters;

  final List<MethodSpec> methods;

  final List<ConstructorSpec> constructors = [];

  final List<PropertySpec> properties;

  final List<OperatorSpec> operatorMethods;

  final String className;

  final TypeToken? superClass;

  final List<TypeToken> implementClasses;

  final List<TypeToken> mixinClasses;

  final List<TypeToken> generics;

  bool get hasGeneric => generics.isNotEmpty;

  bool isAbstract;

  ClassSpec.build(
    this.className, {
    this.doc,
    List<MetaSpec>? metas,
    List<PropertySpec>? properties,
    List<GetterSpec>? getters,
    List<SetterSpec>? setters,
    List<MethodSpec>? methods,
    this.superClass,
    List<TypeToken>? implementClasses,
    List<TypeToken>? mixinClasses,
    List<TypeToken>? generics,
    List<OperatorSpec>? operatorMethods,
    this.isAbstract = false,
    Iterable<ConstructorSpec> Function(ClassSpec owner)? constructorBuilder,
  })
    : this.metas = metas ?? [],
      this.properties = properties ?? [],
      this.getters = getters ?? [],
      this.setters = setters ?? [],
      this.methods = methods ?? [],
      this.implementClasses = implementClasses ?? [],
      this.mixinClasses = mixinClasses ?? [],
      this.generics = generics ?? [],
      this.operatorMethods = operatorMethods ?? []
  {
    if (constructorBuilder != null) constructors.addAll(constructorBuilder(this));
  }

  @override
  String code({Map<String, dynamic> args = const {}}) {
    StringBuffer inner = StringBuffer();
    if (isAbstract) inner.write('abstract ');
    inner.write('class $className');
    if (hasGeneric) inner.write("<${generics.map((o) => o.fullTypeName).join(", ")}>");
    if (superClass != null) inner.write(' extends $superClass');
    if (implementClasses.isNotEmpty) inner.write(' implements ${implementClasses.map((o) => o).join(', ')}');
    if (mixinClasses.isNotEmpty) inner.write(' with ${mixinClasses.join(', ')}');
    inner.writeln(' {');
    var blocks = [];
    String constructorsBlock = collectConstructors(constructors);
    String gettersBlock = collectGetters(getters);
    String settersBlock = collectSetters(setters);
    String methodsBlock = collectMethods(methods);
    String propertiesBlock = collectProperties(properties);
    String operatorsBlock = collectOperatorMethods(operatorMethods);
    if (propertiesBlock.isNotEmpty) blocks.add(propertiesBlock);
    if (constructorsBlock.isNotEmpty) blocks.add(constructorsBlock);
    if (gettersBlock.isNotEmpty) blocks.add(gettersBlock);
    if (settersBlock.isNotEmpty) blocks.add(settersBlock);
    if (methodsBlock.isNotEmpty) blocks.add(methodsBlock);
    if (operatorsBlock.isNotEmpty) blocks.add(operatorsBlock);
    inner.write(blocks.join('\n\n'));
    inner..writeln()..writeln('}');
    String raw = inner.toString();
    raw = collectWithMeta(metas, raw);
    raw = collectWithDoc(doc, raw);
    return raw;
  }
}

String collectClasses(List<ClassSpec> classes) {
  return classes.map((o) => o.code()).join('\n');
}

class ConstructorSpec implements Spec {
  final DocSpec? doc;

  final ClassSpec owner;

  final ConstructorMode mode;

  final List<ParameterSpec> parameters;

  final CodeBlockSpec? codeBlock;

  final String? inherit;

  final String? name;

//todo initializer list

  ConstructorSpec.build(
    this.owner, {
    this.doc,
    required this.mode,
    this.parameters = const [],
    this.codeBlock,
    this.inherit,
    this.name,
  });

  ConstructorSpec.normal(
    ClassSpec owner, {
    List<ParameterSpec> parameters = const [],
    CodeBlockSpec? codeBlock,
    String? inherit,
    DocSpec? doc,
  }) : this.build(
          owner,
          parameters: parameters,
          codeBlock: codeBlock,
          inherit: inherit,
          mode: ConstructorMode.normal,
          doc: doc,
        );

  ConstructorSpec.named(
    ClassSpec owner,
    String name, {
    List<ParameterSpec> parameters = const [],
    CodeBlockSpec? codeBlock,
    String? inherit,
    DocSpec? doc,
  }) : this.build(
          owner,
          parameters: parameters,
          codeBlock: codeBlock,
          inherit: inherit,
          mode: ConstructorMode.named,
          name: name,
          doc: doc,
        );

  ConstructorSpec.factory(
    ClassSpec owner, {
    List<ParameterSpec> parameters = const [],
    CodeBlockSpec? codeBlock,
    String? inherit,
    DocSpec? doc,
  }) : this.build(
          owner,
          parameters: parameters,
          codeBlock: codeBlock,
          inherit: inherit,
          mode: ConstructorMode.factory,
          doc: doc,
        );

  ConstructorSpec.namedFactory(
    ClassSpec owner,
    String name, {
    List<ParameterSpec> parameters = const [],
    CodeBlockSpec? codeBlock,
    String? inherit,
    DocSpec? doc,
  }) : this.build(
          owner,
          parameters: parameters,
          codeBlock: codeBlock,
          inherit: inherit,
          mode: ConstructorMode.namedFactory,
          doc: doc,
          name: name,
        );

  String get _constructorName => owner.className;

  @override
  String code({Map<String, dynamic> args = const {}}) {
    String raw = '';
    switch (mode) {
      case ConstructorMode.normal:
        raw += '$_constructorName(${collectParameters(parameters)})';
        break;
      case ConstructorMode.factory:
        raw += 'factory $_constructorName(${collectParameters(parameters)})';
        break;
      case ConstructorMode.named:
        raw += '$_constructorName.$name(${collectParameters(parameters)})';
        break;
      case ConstructorMode.namedFactory:
        raw += 'factory ${owner.className}.$name(${collectParameters(parameters)})';
        break;
    }
    if (inherit != null) {
      raw += ' : $inherit';
    }
    raw += '${collectCodeBlock(codeBlock)}';
    raw = collectWithDoc(doc, raw);
    return raw;
  }
}

String collectConstructors(List<ConstructorSpec> constructors) {
  return constructors.map((o) => o.code()).join('\n');
}

enum ConstructorMode { normal, factory, named, namedFactory }
