/// Resultado de operações que podem falhar, sem lançar exceções para a UI.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T value) ok,
    required R Function(String message) err,
  }) {
    final self = this;
    return switch (self) {
      Ok<T>(:final value) => ok(value),
      Err<T>(:final message) => err(message),
    };
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.message);
  final String message;
}
