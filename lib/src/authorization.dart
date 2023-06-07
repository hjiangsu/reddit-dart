part of './reddit.dart';

/// Authorization information for a given Reddit instance.
class Authorization {
  late Reddit _reddit;
  late String? _callbackURL;
  late String? _userUuid;

  Map<String, dynamic> authorizationInformation = {};

  Authorization._create({required Reddit reddit, String? callbackURL, String? userUuid}) {
    _reddit = reddit;
    _callbackURL = callbackURL;
    _userUuid = userUuid;
  }

  /// Factory function to generate the Authorization instance
  static Future<Authorization> create({required Reddit reddit, String? callbackURL, String? userUuid}) async {
    Authorization authorizationInstance = Authorization._create(reddit: reddit, callbackURL: callbackURL, userUuid: userUuid);

    // Do initialization that requires async
    await authorizationInstance._initialize(clientId: reddit.clientId, clientSecret: reddit.clientSecret);

    // Return the fully initialized object
    return authorizationInstance;
  }

  /// Initialization function for Authorization class
  _initialize({required String clientId, required String clientSecret}) async {
    const String url = "$_redditURL/api/v1/access_token";

    Map<String, String> headers = {
      "host": "www.reddit.com",
      "authorization": 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
    };

    try {
      final Response response = await dio.post(
        url,
        data: {
          "grant_type": "$_oauthRedditURL/grants/installed_client",
          "device_id": _userUuid,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: headers,
        ),
      );

      authorizationInformation = response.data;
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Performs user re-authorization with a given refresh token. A callback URL must be specified in the creation of the authorization instance.
  /// The callback must provide a JSON response with the associated information.
  refreshUserAuthorization({required String refreshToken}) async {
    if (_callbackURL == null) {
      throw Exception("Missing callback URL to refresh user token");
    }

    final Response response = await dio.post(
      _callbackURL!,
      data: {
        "refresh_token": refreshToken,
        "device_id": _userUuid,
      },
    );

    authorizationInformation = jsonDecode(response.data);
  }

  /// Performs re-authorization for the client and/or user. If refreshCredentials is provided, it will attempt to refresh the access token for the given user.
  ///
  /// The refreshCredential parameter should contain the following keys: access_token, refresh_token.
  /// If any of those keys are missing, then an error will be thrown.
  reauthorize({Map<String, dynamic>? refreshCredentials}) async {
    if (refreshCredentials != null) {
      // Re-authorize with a given user who has previously been authorized
      if (!refreshCredentials.containsKey("access_token") || !refreshCredentials.containsKey("refresh_token")) {
        throw Exception('Re-authorization failed because refreshCredentials keys were not properly provided');
      }

      final refreshToken = refreshCredentials["refresh_token"];
      await refreshUserAuthorization(refreshToken: refreshToken);
    } else {
      // Re-authorize with normal client id and secret
      await _initialize(clientId: _reddit.clientId, clientSecret: _reddit.clientSecret);
    }
  }

  /// Sets the authorization information manually from a given auth parameter.
  setAuthorization(Map<String, dynamic> auth) {
    authorizationInformation = auth;
  }

  String? get accessToken => authorizationInformation["access_token"];
  bool get isInitialized => authorizationInformation.isNotEmpty;
  bool get isUserAuthenticated => authorizationInformation.containsKey("refresh_token");
}
