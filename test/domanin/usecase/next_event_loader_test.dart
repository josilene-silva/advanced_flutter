import 'dart:math';

import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:flutter_test/flutter_test.dart';

class NextEvent {
  final String groupName;
  final DateTime date;
  final List<NextEventPlayer> players;

  NextEvent({
    required this.groupName,
    required this.date,
    required this.players,
  });
}

class NextEventLoader {
  final LoadNextEventRepository repository;

  NextEventLoader({required this.repository});

  Future<NextEvent> call({required String groupId}) async {
    return repository.loadNextEvent(groupId: groupId);
  }
}

abstract class LoadNextEventRepository {
  Future<NextEvent> loadNextEvent({required String groupId});
}

class LoadNextEventMockRepository implements LoadNextEventRepository {
  String? groupId;
  var callsCount = 0;
  NextEvent? output;

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) async {
    this.groupId = groupId;
    callsCount++;
    return output!;
  }
}

void main() {
  late String groupId;
  late LoadNextEventMockRepository repository;
  late NextEventLoader sut;

  setUp(() {
    groupId = Random().nextInt(1000).toString();
    repository = LoadNextEventMockRepository();
    repository.output = NextEvent(
      groupName: 'any group name',
      date: DateTime.now(),
      players: [
        NextEventPlayer(
          id: '1',
          name: 'Josilene Silva',
          isConfirmed: true,
          photo: 'https://example.com/photo1.jpg',
          confirmationDate: DateTime.now().add(Duration(days: 2)),
        ),
        NextEventPlayer(
          id: '2',
          name: 'Paulo Costa',
          isConfirmed: false,
          position: 'Goalkeeper',
          confirmationDate: DateTime.now().add(Duration(days: 1)),
        ),
      ],
    );
    sut = NextEventLoader(repository: repository);
  });
  test('should load event data from repository', () async {
    await sut(groupId: groupId);

    expect(repository.groupId, groupId);
    expect(repository.callsCount, 1);
  });

  test('should return event data on success', () async {
    final event = await sut(groupId: groupId);

    expect(event.groupName, repository.output?.groupName);
    expect(event.date, repository.output?.date);
    expect(event.players.length, 2);

    expect(event.players[0].id, repository.output?.players[0].id);
    expect(event.players[0].name, repository.output?.players[0].name);
    expect(event.players[0].initials, isNotEmpty);
    expect(event.players[0].photo, repository.output?.players[0].photo);
    expect(
      event.players[0].isConfirmed,
      repository.output?.players[0].isConfirmed,
    );
    expect(
      event.players[0].confirmationDate,
      repository.output?.players[0].confirmationDate,
    );

    expect(event.players[1].id, repository.output?.players[1].id);
    expect(event.players[1].name, repository.output?.players[1].name);
    expect(event.players[1].initials, isNotEmpty);
    expect(event.players[1].position, repository.output?.players[1].position);
    expect(
      event.players[1].isConfirmed,
      repository.output?.players[1].isConfirmed,
    );
    expect(
      event.players[1].confirmationDate,
      repository.output?.players[1].confirmationDate,
    );
  });
}
