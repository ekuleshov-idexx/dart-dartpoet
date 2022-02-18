class TypeToken {
  final String _typeName;
  final List<TypeToken> _generics;
  final bool _isNullable;

  TypeToken.ofName(this._typeName, [this._generics = const [], this._isNullable = false ]);

  TypeToken.ofName2(String typeName, [List<Type> generics = const [], bool? isNullable ])
      : this.ofName(typeName, generics.map((o) => TypeToken.of(o)).toList(), isNullable ?? false);

  factory TypeToken.ofFullName(String fullTypeName, [ bool? isNullable ]) {
    if(fullTypeName.endsWith('?')) {
      isNullable = true;
      fullTypeName = fullTypeName.substring(0, fullTypeName.length - 1);
    }

    String typeName = resolveTypeName(fullTypeName);
    List<TypeToken> generics = resolveGenerics(fullTypeName).toList();
    return TypeToken.ofName(typeName, generics, isNullable ?? false);
  }

  factory TypeToken.parse(Object obj, [ bool? isNullable ]) => TypeToken.of(obj.runtimeType, isNullable);

  factory TypeToken.of(Type type, [ bool? isNullable ]) => TypeToken.ofFullName(type.toString(), isNullable);

  factory TypeToken.ofDynamic([ bool? isNullable ]) => TypeToken.of(dynamic, isNullable);

  factory TypeToken.ofInt([ bool? isNullable ]) => TypeToken.of(int, isNullable);

  factory TypeToken.ofString([ bool? isNullable ]) => TypeToken.of(String, isNullable);

  factory TypeToken.ofDouble([ bool? isNullable ]) => TypeToken.of(double, isNullable);

  factory TypeToken.ofBool([ bool? isNullable ]) => TypeToken.of(bool, isNullable);

  factory TypeToken.ofVoid() => TypeToken.ofName('void');

  static TypeToken ofListByToken(TypeToken componentType, [ bool? isNullable ]) {
    return TypeToken.ofName('List', [componentType], isNullable ?? false);
  }

  static TypeToken ofListByType(Type componentType, [ bool? isNullable ]) {
    return TypeToken.ofListByToken(TypeToken.of(componentType), isNullable);
  }

  static TypeToken ofMapByToken(TypeToken keyType, TypeToken valueType, [ bool? isNullable ]) {
    return TypeToken.ofName('Map', [keyType, valueType], isNullable ?? false);
  }

  static TypeToken ofMapByType(Type keyType, Type valueType, [ bool? isNullable ]) {
    return TypeToken.ofMapByToken(TypeToken.of(keyType), TypeToken.of(valueType), isNullable);
  }

  static TypeToken ofList<T>([ bool? isNullable ]) {
    return ofListByToken(TypeToken.of(T, isNullable));
  }

  static TypeToken ofMap<K, V>([ bool? isNullable ]) {
    return ofMapByToken(TypeToken.of(K), TypeToken.of(V), isNullable);
  }

  String get typeName => _typeName;

  bool get isNullable => _isNullable;

  String get fullTypeName => typeName
      + (generics.isNotEmpty ? '<${generics.join(", ")}>' : '')
      + (_isNullable ? '?' : '');

  bool get isPrimitive => ['int', 'double', 'bool', 'String'].contains(typeName);

  bool get isNotPrimitive => !isPrimitive;

  bool get isInt => typeName == 'int';

  bool get isDouble => typeName == 'double';

  bool get isBool => typeName == 'bool';

  bool get isString => typeName == 'String';

  bool get isList => typeName == 'List';

  bool get isMap => typeName == 'Map';

  bool get isDynamic => typeName == 'dynamic';

  bool get isVoid => typeName == 'void';

  List<TypeToken> get generics => _generics;

  TypeToken get firstGeneric => generics.first;

  TypeToken get secondGeneric => generics[1];

  bool get hasGeneric => generics.isNotEmpty;

  bool get isNativeType {
    try {
      nativeType;
      return true;
    } catch (e) {
      return false;
    }
  }

  Type get nativeType {
    if (isInt) return int;
    if (isDouble) return double;
    if (isBool) return bool;
    if (isString) return String;
    if (isList) return List;
    if (isMap) return Map;
    throw 'this TypeToken is not native type: $fullTypeName';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TypeToken && runtimeType == other.runtimeType && _typeName == other._typeName;

  @override
  int get hashCode => _typeName.hashCode;

  @override
  String toString() => fullTypeName;

  TypeToken operator [](int index) => generics[index];
}

bool isPrimitive(Type type) => TypeToken.of(type).isPrimitive;

bool isInt(Type type) => TypeToken.of(type).isInt;

bool isDouble(Type type) => TypeToken.of(type).isDouble;

bool isBool(Type type) => TypeToken.of(type).isBool;

bool isString(Type type) => TypeToken.of(type).isString;

bool isList(Type type) => TypeToken.of(type).isList;

bool isMap(Type type) => TypeToken.of(type).isMap;

String resolveTypeName(String fullTypeName) {
  var regex = RegExp('([a-zA-Z0-9\$_]+)(<((.+))>)?');
  return regex.firstMatch(fullTypeName)!.group(1)!;
}

Iterable<TypeToken> resolveGenerics(String fullTypeName) sync* {
  String? fullGeneric = _getGenericsString(fullTypeName);
  List<String> genericStrings = _splitGenerics(fullGeneric).toList();
  for (var genericString in genericStrings) {
    String? childGenericString = _getGenericsString(genericString);
    if (childGenericString == null) {
      yield TypeToken.ofName(genericString);
    } else {
      yield TypeToken.ofName(resolveTypeName(genericString), resolveGenerics(genericString).toList());
    }
  }
}

String? _getGenericsString(String typeName) {
  var regex = RegExp('[a-zA-Z0-9\$_]+<((.+))>');
  if (regex.hasMatch(typeName)) {
    return regex.firstMatch(typeName)!.group(1);
  } else {
    return null;
  }
}

Iterable<String> _splitGenerics(String? genericsString) sync* {
  if (genericsString == null) {
    yield* [];
  } else {
    genericsString = genericsString.replaceAll(' ', '');
    String tmp = '';
    bool output = true;
    for (var idx = 0; idx < genericsString.length; idx++) {
      String s = genericsString[idx];
      if (s == ',') {
        if (output) {
          yield tmp;
          tmp = '';
        } else {
          tmp += s;
        }
      } else if (s == '<') {
        output = false;
        tmp += s;
      } else if (s == '>') {
        output = true;
        tmp += s;
      } else {
        tmp += s;
      }
    }
    yield tmp;
  }
}
