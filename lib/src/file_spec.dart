import 'package:dartpoet/dartpoet.dart';

class FileSpec implements Spec {
  final List<DependencySpec> dependencies;
  final List<ClassSpec> classes;
  final List<EnumSpec> enums;
  final List<PropertySpec> properties;
  final List<GetterSpec> getters;
  final List<SetterSpec> setters;
  final List<CodeBlockSpec> codeBlocks;
  final List<MethodSpec> methods;

  FileSpec.build({
    List<MethodSpec>? methods,
    List<ClassSpec>? classes,
    List<EnumSpec>? enums,
    List<PropertySpec>? properties,
    List<GetterSpec>? getters,
    List<SetterSpec>? setters,
    List<CodeBlockSpec>? codeBlocks,
    List<DependencySpec>? dependencies,
  }) :
    this.methods = methods ?? [],
    this.classes = classes ?? [],
    this.enums = enums ?? [],
    this.properties = properties ?? [],
    this.getters = getters ?? [],
    this.setters = setters ?? [],
    this.codeBlocks = codeBlocks ?? [],
    this.dependencies = dependencies ?? [];

  @override
  String code({Map<String, dynamic> args = const {}}) {
    bool reverseClasses = args[KEY_REVERSE_CLASSES] ?? false;
    List<ClassSpec> classes = reverseClasses ? this.classes.reversed.toList() : this.classes;

    StringBuffer inner = StringBuffer();

    String dependenciesBlock = collectDependencies(dependencies);
    if (dependenciesBlock.isNotEmpty) inner..writeln()..writeln(dependenciesBlock);

    String propertiesBlock = collectProperties(properties);
    if (propertiesBlock.isNotEmpty) inner..writeln()..writeln(propertiesBlock);

    String gettersBlock = collectGetters(getters);
    if (gettersBlock.isNotEmpty) inner..writeln()..writeln(gettersBlock);

    String settersBlock = collectSetters(setters);
    if (settersBlock.isNotEmpty) inner..writeln()..writeln(settersBlock);

    String codeBlocksBlock = collectCodeBlocks(codeBlocks);
    if (codeBlocksBlock.isNotEmpty) inner..writeln()..writeln(codeBlocksBlock);

    String enumsBlock = collectEnums(enums);
    if (enumsBlock.isNotEmpty) inner..writeln()..writeln(enumsBlock);

    String classesBlock = collectClasses(classes);
    if (classesBlock.isNotEmpty) inner..writeln()..writeln(classesBlock);

    String methodsBlock = collectMethods(methods);
    if (methodsBlock.isNotEmpty) inner..writeln()..writeln(methodsBlock);

    return inner.toString();
  }
}

class DependencySpec implements Spec {
  String route;
  DependencyMode mode;

  DependencySpec.build(
    this.mode,
    this.route,
  );

  DependencySpec.import(String route) : this.build(DependencyMode.import, route);

  DependencySpec.export(String route) : this.build(DependencyMode.export, route);

  DependencySpec.part(String route) : this.build(DependencyMode.part, route);

  DependencySpec.partOf(String route) : this.build(DependencyMode.partOf, route);

  @override
  String code({Map<String, dynamic> args = const {}}) {
    String raw = '';
    switch (mode) {
      case DependencyMode.import:
        raw += "import '$route';";
        break;
      case DependencyMode.export:
        raw += "export '$route';";
        break;
      case DependencyMode.part:
        raw += "part '$route';";
        break;
      case DependencyMode.partOf:
        raw += "part of '$route";
        break;
    }
    return raw;
  }
}

enum DependencyMode { import, export, part, partOf }

String collectDependencies(List<DependencySpec> dependencies) {
  dependencies.sort((o1, o2) => o1.mode.index - o2.mode.index);
  return dependencies.map((o) => o.code()).join('\n');
}
