# Object serialisation in Dart

I have been using [Dart](https://www.dartlang.org/) for a few years now, specifically to produce a complex front-end for our machine vision framework. A recurring theme 
with browser-based applications is the use of JSON to communicate with server-side daemons and the "dart:convert" core package provides reliable 
serialisation/deserialisation capabilities. But one thing Dart cannot do, and I believe it was a mistake to not bake in this ability from the 
beginning, is to support native serialisation/deserialisation of Dart objects.

There have been numerous third-party packages over the years that attempt to address this issue, in fact I dabbled with the mirrors system 
early on and produced [model_map](http://pub.dartlang.org/packages/model_map), but at the time reflection-based code did not compile to javascript properly.

As far as I can tell, the only viable options today are reflection/transformer based solutions and manual serialisation code. I would like to 
propose a third possibility based on the recent javascript interop capabilities of the [js package](https://pub.dartlang.org/packages/js).

## Manual

This method involves writing functions that convert your entity to/from maps which can then be serialised using the core "dart:convert" 
library. If your application contains many complex entities, this means writing an awful lot of boilerplate code and introduces many places 
in which mistakes can be easily made.

```dart
import 'dart:convert';

class Simple
{
    String id;
    double value;
    bool flag;

    static Simple deserialize(dynamic m)
    {
        return m == null ? null : new Simple()
            ..id    = m['id']
            ..value = m['value']?.toDouble() ?? 0.0
            ..flag  = m['flag'] ?? false
        ;
    }

    Map serialize()
    {
        return {
            'id': id,
            'value': value,
            'flag': flag
        };
    }
}
```

which can be encoded and decoded from JSON as follows 

```dart
// Deserialise
var simple = Simple.deserialise(JSON.decode(data));

// Serialise
JSON.encode(simple.serialise());
```

# Reflection and Transformers

An alternative is to use a library that has different behaviours depending on whether you are running in a Dart VM or compiled javascript.

If running in a Dart VM (either command-line or Dartium) then it uses reflection to serialise the class fields. When compiled to javascript 
a transformer is used to generate serialisation/deserialisation code without the need for runtime reflection.

The example provided here is based on the [DSON package](https://pub.dartlang.org/packages/dson). This method results in the least amount of 
boilerplate and is quite an elegant solution considering that object serialisation is not supported natively within Dart.

```dart
part 'simple.g.dart';

@serializable
class Simple extends _$SimpleSerializable
{
    String id;
    double value;
    bool flag;
}
```

which can be encoded and decoded from JSON as follows

```dart
// Deserialize
var simple = fromJson(data, Simple);

// Serialise
toJson(simple);
```

---
Interop Proposal
----------------

The recent development of the [javascript interop package](https://pub.dartlang.org/packages/js) has provided the fundamentals 
for an alternative method of object serialisation.

_Caveat: This method is based on javascript interop and is therefore only of use in browser-based applications. For shared Dart 
entities between the browser and server-side you should use one of the previously mentioned solutions._

A prerequisite of the interop method is to provide direct access to the javascript serialisation functions.

```dart
@JS()
library serialise.interop;

import 'package:js/js.dart';

@JS('JSON.parse')
external dynamic fromJson(String text);

@JS('JSON.stringify')
external String toJson(dynamic object);
```

An entity can then be declared as an anonymous javascript object:

```dart
@JS()
@anonymous
class Simple
{
    external String get id;
    external set id(String value);

    external double get value;
    external set value(double value);

    external bool get flag;
    external set flag(bool value);

    external factory Simple({
        String id,
        double value,
        bool flag
    });
}
```

which can be encoded and decoded from JSON as follows

```dart
// Deserialise
Simple simple = fromJson(data);

// Serialise
toJson(simple);
```

Due to the limitations of interop, fields can not be used and getter/setter functions must be declared instead. 
This results in more boilerplate than the reflection method, but still less than the manual method and with a reduced 
chance of introducing errors.

## Comparison

The following comparisons of size and speed were produced using the code in this repository and Dart v1.22.1, DSON v0.5.0+2,
js v0.6.1, Dartium 45.0.2454.104 and Chrome 57.0.2987.110.

The full results can be found in the [results](results/results.ods) spreadsheet. Each row in the spreadsheet represents 1000 
iterations of serialisation and 1000 iterations of deserialisation of a non-trivial entity. The numbers shown here are averages
and ignore the first half-dozen runs. 

| Method        | Size (js) | Serialize (dart) | Deserialize (dart) | Serialize (js) | Deserialize (js) |
| ------------- | --------- | ---------------- | ------------------ | -------------- | ---------------- |
| Manual        | 39.4 KB   | 8.29 ms          | 5.78 ms            | 10.7 ms        | 7.9 ms           |
| DSON          | 64 KB     | 15.9 ms          | 9.6 ms             | 27.78 ms       | 19.99 ms         |
| Interop       | 33.4 KB   | 61.55 ms         | 14.96 ms           | 2.49 ms        | 2.93 ms          |
| Serializable  | 54 KB     | 6.1 ms           | 6.92 ms            | 4.37 ms        | 8.38 ms          |
| Dartson       | 86 KB     | 9.61 ms          | 6.81 ms            | 8.58 ms        | 7.01 ms          |
| Jaguar_serializer | 88 KB | 8.57 ms          | 6.58 ms            | 10.31 ms       | 8.59 ms          |
| Jackson (Groovy) |        | 496 ms           | 252 ms             | n/a            | n/a              |


## Conclusions

The interop method is clearly the winner when compiled to javascript. Also resulted in
 the smallest javascript file size. However the this method doesn't work if we want to use it in a
 server-side DartVM or Flutter app.

Even though the other methods (Manual, Serializable, Dartson and Jaguar_serializer) has pretty similar speeds and
are faster than DSON, this one has more flexibility for converting values. For example DSON is able to convert values
that contains cyclical references. Also it is able to exclude certain properties and setting the depth of parsing by
passing certain parameters int the `toJson/fromJson` methods. Furthermore you can see that the speed is still much
smaller that Jackson Serializer (Java/Groovy Library).

In my opinion I prefer to sacrifice some speed and gain flexibility. That's why I prefer to use DSON over the other
libraries. However that's just me, and my opinion could be completely biased since I'm the creator and maintainer of
DSON and Serializable.
