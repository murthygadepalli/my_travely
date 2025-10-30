import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth_repository.dart';

// EVENTS
abstract class AuthEvent {}

class RegisterDeviceEvent extends AuthEvent {
  final Map<String, dynamic> body;
  RegisterDeviceEvent(this.body);
}

// STATES
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String visitorToken;
  AuthSuccess(this.visitorToken);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

// BLOC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  AuthBloc(this._repository) : super(AuthInitial()) {
    on<RegisterDeviceEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await _repository.registerDevice(event.body);
        emit(AuthSuccess(token));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
