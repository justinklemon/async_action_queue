import 'dart:async';

import 'package:async_action_queue/async_action_queue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';


Future<String> temp(String tmp) async {
  return "Hello darkness: $tmp";
}

void main() {
  test('async_action', () async{
    AsyncActionQueue queue = AsyncActionQueue();
    Future<String> result = queue.addJobAsync<String>(() => temp("1"));
    queue.addJobAsync<String>(() => temp("2")).then((value) => debugPrint("Result: $value"));
    queue.addJobAsync<String>(() => temp("3")).then((value) => debugPrint("Result: $value"));
    Future<String> result1 = queue.addJobAsync<String>(testJob<String>(const Duration(milliseconds: 1100), "1"));
    Future<String> result2 = queue.addJobAsync<String>(testJob<String>(const Duration(milliseconds: 2100), "2"));
    Future<String> result3 = queue.addJobAsync<String>(testJob<String>(const Duration(milliseconds: 3100), "3"));
    Future<String> result4 = queue.addJobAsync<String>(testJob<String>(const Duration(milliseconds: 1100), "4"));
    Future<String> result5 = queue.addJobAsync<String>(testJob<String>(const Duration(milliseconds: 2100), "5"));
    Future<String> result6 = queue.addJobAsync<String>(testJob<String>(const Duration(milliseconds: 3100), "6"));
    Future<String> result7 = queue.addJobAsync<String>(() async => "7");

    // print every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      debugPrint("Timer: ${timer.tick}");
    });
    
    result.then((value) => debugPrint("Result: $value"));

    expect(result1, completion("1"));
    expect(result2, completion("2"));
    expect(result3, completion("3"));
    expect(result4, completion("4"));
    expect(result5, completion("5"));
    expect(result6, completion("6"));
    expect(result7, completion("7"));
    await queue.queueDoneFuture;
  });
}

Future<T> Function() testJob<T>(Duration duration, T result) {
  return () async {
    await Future.delayed(duration);
    debugPrint("Job done after $duration, returning $result");
    return result;
  };
}