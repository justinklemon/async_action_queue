import 'dart:async';

import 'package:async_queue/async_queue.dart';

class AsyncActionQueue {
  final _queue = AsyncQueue.autoStart();
  int _jobCount = 0;
  Completer<void> _queueCompleter = Completer<void>();
  AsyncActionQueue(){
    _queue.addQueueListener((QueueEvent event) {
      if (event.type == QueueEventType.queueEnd) {
        _queueCompleter.complete();
        _queueCompleter = Completer<void>();
      }
    });
  }
  Future<T> addJobAsync<T>(Future<T> Function() job, {
  String? label,
  String? description,
  int retryTime = 1,
}) async {
    final Completer<T> completer = Completer<T>();
    _queue.addJob((_) async {
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
  Future<void> get queueDoneFuture => _queueCompleter.future;
}