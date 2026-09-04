/// Typed failure hierarchy for KalaSetuV2
sealed class AppFailure {
  const AppFailure();
}

class NetworkFailure extends AppFailure {
  final String message;
  final int? statusCode;
  const NetworkFailure(this.message, {this.statusCode});
  @override
  String toString() => 'NetworkFailure($statusCode): $message';
}

class AuthFailure extends AppFailure {
  final String message;
  const AuthFailure(this.message);
  @override
  String toString() => 'AuthFailure: $message';
}

class ParseFailure extends AppFailure {
  final String message;
  const ParseFailure(this.message);
  @override
  String toString() => 'ParseFailure: $message';
}

class OfflineFailure extends AppFailure {
  const OfflineFailure();
  @override
  String toString() => 'OfflineFailure: No internet connection';
}

class UnknownFailure extends AppFailure {
  final String message;
  const UnknownFailure(this.message);
  @override
  String toString() => 'UnknownFailure: $message';
}

class ValidationFailure extends AppFailure {
  final String field;
  final String message;
  const ValidationFailure(this.field, this.message);
  @override
  String toString() => 'ValidationFailure($field): $message';
}

/// Simple Result wrapper
sealed class Result<T> {
  const Result();
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final AppFailure failure;
  const Err(this.failure);
}

extension ResultExtension<T> on Result<T> {
  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;
  T get value => (this as Ok<T>).value;
  AppFailure get failure => (this as Err<T>).failure;

  R when<R>({required R Function(T) ok, required R Function(AppFailure) err}) {
    return switch (this) {
      Ok<T> ok_ => ok(ok_.value),
      Err<T> err_ => err(err_.failure),
    };
  }
}
