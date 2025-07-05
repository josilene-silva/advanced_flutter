import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

class NextEventLoader {
  final LoadNextEventRepository repository;

  NextEventLoader({required this.repository});

  Future<void> call({required String groupId}) async {
    await repository.loadNextEvent(groupId: groupId);
  }
}

abstract class LoadNextEventRepository {
  Future<void> loadNextEvent({required String groupId});
}

class LoadNextEventMockRepository implements LoadNextEventRepository {
  String? groupId;
  var callsCount = 0;

  @override
  Future<void> loadNextEvent({required String groupId}) async {
    this.groupId = groupId;
    callsCount++;
  }
}

void main() {
  test('should load event data from repository', () async {
    final groupId = Random().nextInt(1000).toString();
    final repository = LoadNextEventMockRepository();
    final sut = NextEventLoader(repository: repository);

    await sut(groupId: groupId);

    expect(repository.callsCount, 1);
  });
}
