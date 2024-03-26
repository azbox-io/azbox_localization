class ResponseStatusCode {
  static const ok = 200;
  static const accepted = 202;
  static const badRequest = 400;
  static const unauthorized = 401;
  static const forbidden = 403;
  static const payloadTooLarge = 413;

  static const List<int> successCodes = [
    ResponseStatusCode.ok,
    ResponseStatusCode.accepted
  ];

  static const List<int> errorCodes = [
    ResponseStatusCode.badRequest,
    ResponseStatusCode.unauthorized,
    ResponseStatusCode.forbidden,
    ResponseStatusCode.payloadTooLarge
  ];
}