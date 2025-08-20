class Result<T> {
  final T? data;
  final Object? error;
  const Result._(this.data, this.error);

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  static Result<T> ok<T>(T data) => Result._(data, null);
  static Result<T> fail<T>(Object error) => Result._(null, error);
}
