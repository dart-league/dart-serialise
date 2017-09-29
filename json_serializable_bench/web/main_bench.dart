library serialise.manual;

import 'dart:convert';
import 'dart:html';

import 'package:json_annotation/json_annotation.dart';

part 'main_bench.g.dart';

@JsonSerializable()
class Simple extends _$SimpleSerializerMixin {
  String id;
  double value;
  bool flag;

  Simple({
    this.id,
    this.value,
    this.flag
  });

  factory Simple.fromJson(Map<String, dynamic> json) => _$SimpleFromJson(json);
}

@JsonSerializable()
class Complex extends _$ComplexSerializerMixin {
  Simple simple;
  List<Simple> list;

  Complex({
    this.simple,
    this.list
  });

  factory Complex.fromJson(Map<String, dynamic> json) => _$ComplexFromJson(json);
}


void main() {
  String data = '''{
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
	}''';

  var output = document.querySelector('#output');

  int serializeTimeTotal = 0;
  int deserializeTimeTotal = 0;

  for (int j = 0; j < 50; j++) {
    var s = new Stopwatch()
      ..start();

    for (int i = 0; i < 1000; i++) {
      var complex = new Complex(
          list: [
            new Simple(id: "item 0", value: 0.0, flag: true),
            new Simple(id: "item 1", value: 1.0, flag: false),
            new Simple(id: "item 2", value: 2.0, flag: true)
          ],
          simple: new Simple(id: "something", value: 42.0, flag: true)
      );

      JSON.encode(complex);
    }

    s.stop();

    int serializeTime = s.elapsedMicroseconds;
    serializeTimeTotal += serializeTime;

    s
      ..reset()
      ..start();

    for (int i = 0; i < 1000; i++) {
      new Complex.fromJson(JSON.decode(data));
    }

    s.stop();

    var deserializeTime = s.elapsedMicroseconds;
    deserializeTimeTotal += deserializeTime;

    output.appendHtml("<tr><td>$serializeTime</td><td>${deserializeTime}</td>");
  }

  output.appendHtml("<tr><th>${serializeTimeTotal / 50}</th><th>${deserializeTimeTotal / 50}</th></tr>");
}
