import 'package:flutter_test/flutter_test.dart';

import 'package:advanced_flutter/infra/api/repositories/load_next_event_http_repository.dart';
import 'package:advanced_flutter/domain/entities/domain_error.dart';

import '../../../helpers/fakes.dart';
import '../clients/http_client_spy.dart';

void main() {
  late String groupId;
  late String url;
  late HttpClientSpy httpClient;
  late LoadNextEventHttpRepository sut;

  setUpAll(() {
    url = 'https://api.example.com/groups/:groupId/events/next';
  });

  setUp(() {
    groupId = anyString();
    httpClient = HttpClientSpy();
    httpClient.responseJson = '''
      {
        "groupName": "any_name",
        "date": "2025-08-01T12:00:00",
        "players": [
          {
            "id": "any_id",
            "name": "any_name",
            "isConfirmed": true
          },
          {
            "id": "any_id 2",
            "name": "any_name 2",
            "isConfirmed": false,
            "photo": "any_photo 2",
            "position": "any_position 2",
            "confirmationDate": "2025-07-01T12:00:00"
          }
        ]
      }
    ''';
    sut = LoadNextEventHttpRepository(httpClient: httpClient, url: url);
  });
  test('should request with correct method', () async {
    await sut.loadNextEvent(groupId: groupId);

    expect(httpClient.method, 'get');
    expect(httpClient.callsCount, 1);
  });

  test('should request with correct url', () async {
    await sut.loadNextEvent(groupId: groupId);

    expect(
      httpClient.url,
      'https://api.example.com/groups/$groupId/events/next',
    );
  });

  test('should request with correct headers', () async {
    await sut.loadNextEvent(groupId: groupId);

    expect(httpClient.headers?['content-type'], 'application/json');
    expect(httpClient.headers?['accept'], 'application/json');
  });

  test('should return NetEvent on 200', () async {
    final event = await sut.loadNextEvent(groupId: groupId);

    expect(event.groupName, 'any_name');
    expect(event.date, DateTime(2025, 8, 1, 12, 0, 0));

    expect(event.players[0].id, 'any_id');
    expect(event.players[0].name, 'any_name');
    expect(event.players[0].isConfirmed, true);

    expect(event.players[1].id, 'any_id 2');
    expect(event.players[1].name, 'any_name 2');
    expect(event.players[1].isConfirmed, false);
    expect(event.players[1].photo, 'any_photo 2');
    expect(event.players[1].position, 'any_position 2');
    expect(event.players[1].confirmationDate, DateTime(2025, 7, 1, 12, 0, 0));
  });

  test('should return UnexpectedError on 400', () async {
    httpClient.simulateBadRequestError();
    final future = sut.loadNextEvent(groupId: groupId);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should return SessionExpiredError on 401', () async {
    httpClient.simulateUnauthorizedError();
    final future = sut.loadNextEvent(groupId: groupId);

    expect(future, throwsA(DomainError.sessionExpired));
  });

  test('should return UnexpectedError on 403', () async {
    httpClient.simulateForbiddenError();
    final future = sut.loadNextEvent(groupId: groupId);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should return UnexpectedError on 404', () async {
    httpClient.simulateNotFoundError();
    final future = sut.loadNextEvent(groupId: groupId);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should return UnexpectedError on 500', () async {
    httpClient.simulateServerError();
    final future = sut.loadNextEvent(groupId: groupId);

    expect(future, throwsA(DomainError.unexpected));
  });
}
