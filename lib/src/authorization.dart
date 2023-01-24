part of './reddit.dart';

class Authorization {
  late Reddit _reddit;

  Map<String, dynamic> authorizationInformation = {};

  Authorization._create({required Reddit reddit}) {
    _reddit = reddit;
  }

  /// Factory function to generate the Authorization instance
  static Future<Authorization> create({required Reddit reddit}) async {
    Authorization authorizationInstance = Authorization._create(reddit: reddit);

    // Do initialization that requires async
    await authorizationInstance._initialize(clientId: reddit.clientId, clientSecret: reddit.clientSecret);

    // Return the fully initialized object
    return authorizationInstance;
  }

  /// Initialization function for Authorization class
  _initialize({required String clientId, required String clientSecret}) async {
    const String url = "$redditURL/api/v1/access_token";

    // This device id should be per user per device
    // @todo - change the device id to be retrieved from the device itself
    const String deviceId = "88fd40ce-b4c7-47f3-9662-1703721dd760";

    Map<String, String> headers = {
      "host": "www.reddit.com",
      "authorization": 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
    };

    try {
      final Response response = await dio.post(
        url,
        data: {
          "grant_type": "$oauthRedditURL/grants/installed_client",
          "device_id": deviceId,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: headers,
        ),
      );

      print(response.data);
      authorizationInformation = response.data;
    } catch (e) {
      throw Exception(e);
    }
  }

  refresh({required String refreshToken, required String callbackURL}) async {
    final Response response = await dio.post(
      callbackURL,
      data: {
        "refresh_token": refreshToken,
      },
    );

    print(response.data);
    authorizationInformation = response.data;
  }

  reauthorize() async {
    await _initialize(clientId: _reddit.clientId, clientSecret: _reddit.clientSecret);
  }

  setAuthorization(Map<String, dynamic> auth) {
    authorizationInformation = auth;
  }

  String? get accessToken => authorizationInformation["access_token"];
  bool get isInitialized => authorizationInformation.isNotEmpty;
}
