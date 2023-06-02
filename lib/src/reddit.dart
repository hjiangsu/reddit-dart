import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:reddit/src/comment.dart';
import 'package:reddit/src/utils/parse.dart';
import 'package:reddit/src/utils/ratelimit.dart';

part 'authorization.dart';
part 'subreddit.dart';
part 'submission.dart';
part 'comment_tree.dart';
part 'front.dart';
part 'redditor.dart';
part 'search.dart';

Dio dio = Dio();

const String _redditURL = 'https://reddit.com';
const String _oauthRedditURL = 'https://oauth.reddit.com';

/// Class containing optional parameters for the Reddit instance.
class RedditOptions {
  final Dio? dio;
  final String? callbackURL;

  RedditOptions({this.dio, this.callbackURL});
}

/// Reddit class used to instantiate/call functions related to the library.
class Reddit {
  final String clientId;
  final String clientSecret;
  final String userAgent;

  RedditOptions? options;
  Authorization? authorization;

  RateLimit rateLimit = RateLimit();

  Reddit({required this.clientId, required this.clientSecret, required this.userAgent, this.options});

  /// Perfoms a request to Reddit's OAuth endpoints.
  /// You should **not** need to call this function directly. If you need to request for a resource, use the appropriate function.
  ///
  /// The parameter `method` takes one of `GET`, `POST`
  Future<dynamic> request({required String method, required String endpoint, Map<String, dynamic>? params}) async {
    if (authorization == null || !authorization!.isInitialized) await authorize();

    String url = "$_oauthRedditURL$endpoint";

    Map<String, String> headers = {
      "User-Agent": userAgent,
      "Authorization": "bearer ${authorization!.accessToken}",
    };

    Response? response;

    try {
      if (method == "GET") {
        response = await dio.get(
          url,
          queryParameters: params,
          options: Options(headers: headers),
        );
      } else if (method == "POST") {
        response = await dio.post(
          url,
          data: params,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: headers,
          ),
        );
      }

      if (response?.headers != null) {
        String? ratelimitUsed = response?.headers.value('X-Ratelimit-Used');
        String? ratelimitRemaining = response?.headers.value('X-Ratelimit-Remaining');
        String? ratelimitReset = response?.headers.value('X-Ratelimit-Reset');

        rateLimit.setRemaining(double.parse(ratelimitRemaining!));
        rateLimit.setUsed(double.parse(ratelimitUsed!));
        rateLimit.setResetSeconds(double.parse(ratelimitReset!));

        if (rateLimit.hasExceeded()) {
          throw Exception("Rate limit exceeded and will be reset in ${rateLimit.resetSeconds} seconds");
        } else {
          print("Rate limit: $rateLimit");
        }
      }

      return response?.data;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Authorization?> authorize({String? userUuid}) async {
    authorization = await Authorization.create(reddit: this, callbackURL: options?.callbackURL, userUuid: userUuid);
    return authorization;
  }

  /// Performs functions related to a subreddit.
  ///
  /// By default, it returns back an instance of [Subreddit].
  /// With an instance of Subreddit, you can query for information about the subreddit.
  ///
  /// ```dart
  /// reddit.subreddit("apple").information["display_name"];
  /// reddit.subreddit("apple").information["subscribers"];
  /// ```
  ///
  /// A [List<Submission>] will be returned back for any functions which retrieve back Submissions.
  ///
  /// ```dart
  /// reddit.subreddit("apple").hot();
  /// reddit.subreddit("apple").newest();
  /// reddit.subreddit("apple").rising();
  /// ```
  ///
  /// To get more submissions, you must first call one of the previous methods to retrieve submissions.
  ///
  /// ```dart
  /// reddit.subreddit("apple").hot().more();
  /// ```
  Future<Subreddit> subreddit(String subreddit) async {
    Subreddit subredditInstance = await Subreddit.create(reddit: this, subreddit: subreddit);
    return subredditInstance;
  }

  /// Performs functions related to a submission.
  ///
  /// By default, it returns back an instance of [Submission].
  /// With an instance of Submission, you can query for information about that submission.
  ///
  /// ```dart
  /// reddit.submission("5or86n").information["title"];
  /// reddit.submission("5or86n").information["permalink"];
  /// ```
  dynamic submission(String id, {bool? fetchComments}) async {
    Submission submission = await Submission.create(reddit: this, id: id, fetchComments: fetchComments);
    return submission;
  }

  /// Performs functions related to a comments.
  ///
  /// By default, it returns back an instance of [CommentTree].
  /// With an instance of CommentTree, you can obtain the replies of the particular Comment.
  /// The result returns a [List<Comment>], with the first element of the list being the parent comment.
  ///
  /// ```dart
  /// reddit.commentTree(submissionId: "5or86n", commentId: "dcleoq1");
  /// reddit.commentTree(submissionId: "5or86n", commentId: "dcleoq1").comments;
  /// ```
  dynamic commentTree({required String submissionId, String? commentId, String? subreddit, String? sort}) async {
    // Retrieve a commment tree
    CommentTree commentTree = await CommentTree.create(reddit: this, submissionId: submissionId, commentId: commentId, subreddit: subreddit, sort: sort);
    return commentTree;
  }

  /// Performs functions related to a subreddit at the home page.
  ///
  /// By default, it returns back an instance of [Front].
  /// A [List<Submission>] will be returned back for any functions which retrieve back Submissions.
  ///
  /// ```dart
  /// reddit.front("popular").hot();
  /// reddit.front("popular").newest();
  /// reddit.front("popular").rising();
  /// ```
  ///
  /// To get more submissions, you must first call one of the previous methods to retrieve submissions.
  ///
  /// ```dart
  /// reddit.front("popular").hot().more();
  /// ```
  Future<Front> front(String type) async {
    Front frontInstance = await Front.create(reddit: this, type: type);
    return frontInstance;
  }

  /// Performs functions related a given user - either the currently logged in user or as a different user
  ///
  /// By default, it returns back an instance of [Redditor].
  /// You can retrieve the user's subscriptions which returns back a List<Subreddit>
  ///
  /// ```dart
  /// reddit.me();
  /// reddit.me().subscriptions();
  /// ```
  Future<Redditor> me() async {
    Redditor redditor = await Redditor.create(reddit: this);
    return redditor;
  }

  /// Performs functions related a given user. By default, it returns back an instance of [Redditor].
  ///
  /// ```dart
  /// reddit.redditor(username: "username");
  /// ```
  Future<Redditor> redditor({required String username}) async {
    Redditor redditor = await Redditor.create(reddit: this, username: username);
    return redditor;
  }

  /// Performs functions related to search. Currently enables searching for subreddits and users
  ///
  /// By default, it returns back an instance of [Search].
  ///
  /// ```dart
  /// reddit.search();
  /// ```
  ///
  /// Searching for a subreddit will return back a List<Subreddit>. You can alter the limit and nsfw flag in the function call.
  /// To continue the search results, call the more() function.
  /// ```dart
  /// searchInstance.search(subredditQuery: "apple", limit: 10, nsfw: false);
  /// searchInstance.more();
  /// ```
  ///
  /// Searching for a user will return back a List<Redditor>. You can alter the limit and nsfw flag in the function call.
  /// ```dart
  /// searchInstance.search(userQuery: "ther", limit: 10, nsfw: false);
  /// ```
  Future<Search> search() async {
    Search search = await Search.create(reddit: this);
    return search;
  }
}
