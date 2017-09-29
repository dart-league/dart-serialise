// GENERATED CODE - DO NOT MODIFY BY HAND

part of serialise.serializable_bench;

// **************************************************************************
// Generator: SerializableGenerator
// **************************************************************************

abstract class _$SimpleSerializable extends SerializableMap {
  String get id;
  double get value;
  bool get flag;
  void set id(String v);
  void set value(double v);
  void set flag(bool v);

  operator [](Object key) {
    switch (key) {
      case 'id':
        return id;
      case 'value':
        return value;
      case 'flag':
        return flag;
    }
    throwFieldNotFoundException(key, 'Simple');
  }

  operator []=(Object key, value) {
    switch (key) {
      case 'id':
        id = value;
        return;
      case 'value':
        value = value;
        return;
      case 'flag':
        flag = value;
        return;
    }
    throwFieldNotFoundException(key, 'Simple');
  }

  Iterable<String> get keys => const ['id', 'value', 'flag'];
}

abstract class _$ComplexSerializable extends SerializableMap {
  Simple get simple;
  List<Simple> get list;
  void set simple(Simple v);
  void set list(List<Simple> v);

  operator [](Object key) {
    switch (key) {
      case 'simple':
        return simple;
      case 'list':
        return list;
    }
    throwFieldNotFoundException(key, 'Complex');
  }

  operator []=(Object key, value) {
    switch (key) {
      case 'simple':
        simple = value;
        return;
      case 'list':
        list = value;
        return;
    }
    throwFieldNotFoundException(key, 'Complex');
  }

  Iterable<String> get keys => const ['simple', 'list'];
}
