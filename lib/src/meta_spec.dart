import 'package:dartpoet/dartpoet.dart';

class MetaSpec implements Spec {
  final TypeToken? typeToken;
  final List<ParameterSpec> parameters;
  final String? instanceName;
  final bool isInstance;

  MetaSpec.ofInstance(this.instanceName)
      : isInstance = true, typeToken = null, parameters = const [];

  MetaSpec.ofConstructor(this.typeToken, { this.parameters = const [] })
      : isInstance = false, instanceName = null;

  @override
  String code({Map<String, dynamic> args = const {}}) {
    if (isInstance) {
      return '@$instanceName';
    } else {
      var list = parameters.where((o) => o.isValue).toList();
      list.sort((o1, o2) => o1.parameterMode.index - o2.parameterMode.index);
      return "@${typeToken!.fullTypeName}(${list.map((o) => o.code()).join(", ")})";
    }
  }
}

String collectMetas(List<MetaSpec> metas) {
  return metas.map((o) => o.code()).join('\n');
}

String collectWithMeta(List<MetaSpec> metas, String raw) {
  if (metas.isEmpty) return raw;
  return '${collectMetas(metas)}\n$raw';
}
