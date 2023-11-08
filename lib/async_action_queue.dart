import 'dart:async';

import 'package:async_queue/async_queue.dart';

class AsyncActionQueue {
  final _queue = AsyncQueue.autoStart();
  int _jobCount = 0;
  QueueEventType? _lastEvent; 
  AsyncActionQueue(){
    _queue.addQueueListener((QueueEvent event) {
      _lastEvent = event.type;
    });
  }
  Future<dynamic> addJobAsync(Future<dynamic> Function() job, {
  String? label,
  String? description,
  int retryTime = 1,
}) async {
    final Completer<dynamic> completer = Completer<dynamic>();
    _queue.addJob(() async {
      try {
        final result = await job();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    }, label: label ?? "job${_jobCount++}", description: description, retryTime: retryTime);
    return completer.future;
  }

  // Can be used by the KeepAliveLinkController to determine if the queue is done
  bool isQueueDone() => _lastEvent == QueueEventType.queueEnd;
}