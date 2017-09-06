import 'package:build_runner/build_runner.dart';
import 'package:dson/phase.dart';


main() async {
  await build([dsonPhase(const ['web/dson.dart', 'web/dson_bench.dart'])],
      deleteFilesByDefault: true);
}
