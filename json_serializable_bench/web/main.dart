library serialise.manual;

import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
// import 'dart:html';

part 'main.g.dart';

@JsonSerializable()
class Simple extends _$SimpleSerializerMixin {
  String id;
  double value;
  bool flag;

  Simple();

  factory Simple.fromJson(Map<String, dynamic> json) => _$SimpleFromJson(json);
}

@JsonSerializable()
class Complex extends _$ComplexSerializerMixin {
  Simple simple;
  List<Simple> list;

  Complex();

  factory Complex.fromJson(Map<String, dynamic> json) => _$ComplexFromJson(json);
}


void main() {
  var complex = new Complex.fromJson(JSON.decode('''{
		"simple": {
			"id": "something",
			"value": 42.0,
			"flag": true
		},
		"list": [
			{"id":"item 0","value":0,"flag":true},
			{"id":"item 1","value":1,"flag":false},
			{"id":"item 2","value":2,"flag":true}
		]
	}'''));

  print(complex.simple.id);
  print(JSON.encode(JSON.encode(complex)));
}
