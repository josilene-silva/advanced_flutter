import 'package:flutter_test/flutter_test.dart';

class NextEventPlayer {
  final String id;
  final String name;
  final String initials;
  final String? photo;
  final String? position;
  final bool isConfirmed;
  final DateTime? confirmationDate;

  // construtor privado
  NextEventPlayer._({
    required this.id,
    required this.name,
    required this.initials,
    required this.isConfirmed,
    this.photo,
    this.position,
    this.confirmationDate,
  });

  // factory constructor
  // O factory constructor também chama o método _getInitials
  // para obter as iniciais do nome do jogador, que são armazenadas na propriedade initials
  // do objeto NextEventPlayer.
  factory NextEventPlayer({
    required String id,
    required String name,
    required bool isConfirmed,
    String? photo,
    String? position,
    DateTime? confirmationDate,
  }) => NextEventPlayer._(
    id: id,
    name: name,
    isConfirmed: isConfirmed,
    initials: _getInitials(name),
    photo: photo,
    position: position,
    confirmationDate: confirmationDate,
  );

  static String _getInitials(String name) {
    final names = name.split(' ');
    final firstChar = names.first[0];
    final lastChar = names.last[0];
    return '$firstChar$lastChar';
  }
}

void main() {
  String initialsOf(String name) =>
      NextEventPlayer(id: '', name: name, isConfirmed: true).initials;

  test('should return the first letter of the first and last name', () {
    expect(initialsOf('Josilene Silva'), 'JS');

    expect(initialsOf('Paulo Costa'), 'PC');

    expect(initialsOf('Maria Vitória da Silva'), 'MS');
  });
}
