class ResponseStatusCode {
  static const OK = 200;
  static const ACCEPTED = 202;
  static const BAD_REQUEST = 400;
  static const UNAUTHORIZED = 401;
  static const FORBIDDEN = 403;
  static const PAYLOAD_TOO_LARGE = 413;

  static const List<int> SUCCESS_CODES = [
    ResponseStatusCode.OK,
    ResponseStatusCode.ACCEPTED
  ];

  static const List<int> ERROR_CODES = [
    ResponseStatusCode.BAD_REQUEST,
    ResponseStatusCode.UNAUTHORIZED,
    ResponseStatusCode.FORBIDDEN,
    ResponseStatusCode.PAYLOAD_TOO_LARGE
  ];
}