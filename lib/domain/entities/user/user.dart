import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String? image;
  final String email;

  const User({
    required this.id,
    required this.name,
    this.image,
    required this.email,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        image,
      ];
}
