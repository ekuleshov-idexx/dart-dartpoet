
import 'package:dartpoet/dartpoet.dart';

class EnumSpec implements Spec {
  final String name;
  final List<EnumValueSpec> values;
  
  final DocSpec? doc;
  final List<MetaSpec> metas;

  EnumSpec.build(this.name, this.values, { this.doc, this.metas = const [] });

  @override
  String code({Map<String, dynamic> args = const {}}) {
    StringBuffer inner = StringBuffer();
    inner.writeln('enum $name {');
    
    for(EnumValueSpec p in values) {
      inner.writeln(p.code());
    }
    
    inner.writeln('}');
    return inner.toString();
  }
}

class EnumValueSpec implements Spec {
  final DocSpec? doc;
  final String name;

  EnumValueSpec(this.name, { this.doc });

  @override
  String code({Map<String, dynamic> args = const {}}) {
    StringBuffer inner = StringBuffer();
    if(doc != null) {
      inner.writeln(doc!.code());
    }
    inner.writeln('$name,');
    return inner.toString();
  }
}

String collectEnums(List<EnumSpec> enums) {
  return enums.map((o) => o.code()).join('\n');
}
