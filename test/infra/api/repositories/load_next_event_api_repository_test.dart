import 'package:advanced_flutter/infra/api/clients/http_get_client.dart';
import 'package:advanced_flutter/infra/api/repositories/load_next_event_api_repository.dart';
import 'package:advanced_flutter/infra/types/json.dart';

import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

class HttpGetClientSpy implements HttpGetClient {
  String? url;
  int callsCount = 0;
  Json? params;
  dynamic response;
  Error? error;

  @override
  Future<T> get<T>({required String url, Json? params}) async {
    this.url = url;
    this.params = params;
    callsCount++;
    if (error != null) throw error!;
    return response;
  }
}

void main() {
  late String groupId;
  late String url;
  late HttpGetClientSpy httpClient;
  late LoadNextEventApiRepository sut;

  setUp(() {
    groupId = anyString();
    url = anyString();
    httpClient = HttpGetClientSpy();
    httpClient.response = {
      "groupName": "any_name",
      "date": "2025-08-01T12:00:00",
      "players": [
        {"id": "any_id", "name": "any_name", "isConfirmed": true},
        {
          "id": "any_id 2",
          "name": "any_name 2",
          "isConfirmed": false,
          "photo": "any_photo 2",
          "position": "any_position 2",
          "confirmationDate": "2025-07-01T12:00:00",
        },
      ],
    };
    sut = LoadNextEventApiRepository(httpClient: httpClient, url: url);
  });

  test('should call HttpClient with correct input', () async {
    await sut.loadNextEvent(groupId: groupId);

    expect(httpClient.url, url);
    expect(httpClient.params, {'groupId': groupId});
    expect(httpClient.callsCount, 1);
  });

  test('should return NetEvent on success', () async {
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

  test('should rethrow on error', () async {
    final error = Error();
    httpClient.error = error;
    final future = sut.loadNextEvent(groupId: groupId);

    expect(future, throwsA(error));
  });
}
