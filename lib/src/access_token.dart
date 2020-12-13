class AccessToken {
  final String accessToken;
  final DateTime expireAt;
  final DateTime issuedAt;

  AccessToken(this.accessToken, this.expireAt, this.issuedAt);
}
