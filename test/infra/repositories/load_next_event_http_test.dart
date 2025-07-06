import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/domain/repositories/load_next_event_repository.dart';

import '../../helpers/fakes.dart';

enum DomainError { unexpected }

class LoadNextEventHttpRepository implements LoadNextEventRepository {
  final Client httpClient;
  final String url;

  LoadNextEventHttpRepository({required this.httpClient, required this.url});

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final uri = Uri.parse(url.replaceFirst(':groupId', groupId));
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };
    final response = await httpClient.get(uri, headers: headers);
    if (response.statusCode == 400) {
      throw DomainError.unexpected;
    } else if (response.statusCode == 403) {
      throw DomainError.unexpected;
    }
    final event = jsonDecode(response.body);

    return NextEvent(
      groupName: event['groupName'],
      date: DateTime.parse(event['date']),
      players: event['players']
          .map<NextEventPlayer>(
            (player) => NextEventPlayer(
              id: player['id'],
              name: player['name'],
              isConfirmed: player['isConfirmed'],
              photo: player['photo'],
              position: player['position'],
              confirmationDate: DateTime.tryParse(
                player['confirmationDate'] ?? '',
              ),
            ),
          )
          .toList(),
    );
  }
}

class HttpClientSpy implements Client {
  String? method;
  String? url;
  int callsCount = 0;
  Map<String, String>? headers;
  String responseJson = '';
  int statusCode = 200;

  @override
  void close() {}

  @override
  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    method = 'get';
    callsCount++;
    this.url = url.toString();
    this.headers = headers;
    return Response(responseJson, statusCode);
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    throw UnimplementedError();
  }
}

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
    httpClient.statusCode = 400;
    final future = sut.loadNextEvent(groupId: groupId);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should return UnexpectedError on 403', () async {
    httpClient.statusCode = 403;
    final future = sut.loadNextEvent(groupId: groupId);

    expect(future, throwsA(DomainError.unexpected));
  });
}
