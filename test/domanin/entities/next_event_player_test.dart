import 'package:advanced_flutter/domain/entities/next_event_player.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String initialsOf(String name) =>
      NextEventPlayer(id: '', name: name, isConfirmed: true).initials;

  test('should return the first letter of the first and last name', () {
    expect(initialsOf('Josilene Silva'), 'JS');

    expect(initialsOf('Paulo Costa'), 'PC');

    expect(initialsOf('Maria Vitória da Silva'), 'MS');
  });

  test('should return the first letters of the first name', () {
    expect(initialsOf('Josilene'), 'JO');
    expect(initialsOf('J'), 'J');
  });

  test('should return "-" when name is empty', () {
    expect(initialsOf(''), '-');
  });

  test('should convert to uppercase', () {
    expect(initialsOf('josilene silva'), 'JS');

    expect(initialsOf('josilene'), 'JO');
    expect(initialsOf('j'), 'J');
  });

  test('should ignore white spaces', () {
    expect(initialsOf('Josilene Silva '), 'JS');
    expect(initialsOf(' Josilene Silva'), 'JS');
    expect(initialsOf('Josilene  Silva'), 'JS');
    expect(initialsOf(' Josilene  Silva '), 'JS');
    expect(initialsOf(' Josilene '), 'JO');
    expect(initialsOf(' J '), 'J');
    expect(initialsOf('  '), '-');
  });
}
