library serialise.serializable_bench;

import 'package:serializable/serializable.dart';
import 'dart:html';
import 'dart:convert';

part 'main.g.dart';

@serializable
class Simple extends _$SimpleSerializable {
	String id;
	double value;
	bool flag;
}


@serializable
class Complex extends _$ComplexSerializable {
	Simple simple;
	List<Simple> list;

	operator []=(Object key, value) {
		switch (key) {
			case 'simple':
				simple = value == null || value is Simple ? value : (new Simple()..fromMap(value));
				return;
			case 'list':
				list = value == null ? value : (value.map((v) => new Simple()..fromMap(v)).toList());
				return;
		}
		super[key] = value;
	}

}

void main() {
	var output = document.querySelector('#output');

	String data = '''{
		"simple": {
			"id": "something",
			"value": 42.0,
			"flag": true
		},
		"list": [
			{"id":"item 0","value":0.0,"flag":true},
			{"id":"item 1","value":1.0,"flag":false},
			{"id":"item 2","value":2.0,"flag":true}
		]
	}''';

	int serializeTimeTotal = 0;
	int deserializeTimeTotal = 0;

	for (int j=0; j<50; j++) {
		var s = new Stopwatch()..start();

		for (int i=0; i<1000; i++) {
			var complex = new Complex()
				..list = [
					new Simple()..id = "item 0"..value = 0.0..flag = true,
					new Simple()..id = "item 1"..value = 1.0..flag = false,
					new Simple()..id = "item 2"..value = 2.0..flag = true
				]
				..simple = (new Simple()..id = "something"..value = 42.0..flag = true);

			JSON.encode(complex);
		}

		s.stop();

		int serializeTime = s.elapsedMicroseconds;
		serializeTimeTotal += serializeTime;

		s..reset()..start();

		for (int i=0; i<1000; i++) {
			var complexMap = JSON.decode(data);
//			complexMap['simple'] = new Simple()..fromMap(complexMap['simple']);
//			complexMap['list'] = complexMap['list'].map((simpleMap) =>
//				new Simple()..fromMap(simpleMap)).toList();
			new Complex()..fromMap(complexMap);
		}

		s.stop();

		var deserializeTime = s.elapsedMicroseconds;
		deserializeTimeTotal += deserializeTime;

		output.appendHtml("<tr><td>$serializeTime</td><td>${deserializeTime}</td>");
	}

	output.appendHtml("<tr><th>${serializeTimeTotal/50}</th><th>${deserializeTimeTotal/50}</th></tr>");
}
