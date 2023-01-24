import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:reddit/src/comment.dart';
import 'package:reddit/src/utils/parse.dart';

part 'authorization.dart';
part 'subreddit.dart';
part 'submission.dart';
part 'comment_tree.dart';
part 'front.dart';

Dio dio = Dio();

const String redditURL = 'https://reddit.com';
const String oauthRedditURL = 'https://oauth.reddit.com';

class Reddit {
  final String clientId;
  final String clientSecret;
  final String userAgent;

  Authorization? authorization;

  Reddit({required this.clientId, required this.clientSecret, required this.userAgent, Map<String, dynamic>? options}) {
    if (options != null) {
      // Parse any extra options here
      if (options.containsKey('dio')) dio = options['dio'];
      if (options.containsKey('authorizationInformation')) {}
    }
  }

  /// Perfoms a request to Reddit's OAuth endpoints.
  /// You should **not** need to call this function directly. If you need to request for a resource, use the appropriate function.
  ///
  /// The parameter `method` takes one of `GET`, `POST`
  Future<dynamic> request({required String method, required String endpoint, Map<String, dynamic>? params}) async {
    if (authorization == null || !authorization!.isInitialized) await authorize();

    String url = "$oauthRedditURL$endpoint";

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

      return response?.data;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> authorize() async {
    authorization = await Authorization.create(reddit: this);
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
  dynamic submission(String id) async {
    Submission submission = await Submission.create(reddit: this, id: id, fetchComments: true);
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
  dynamic commentTree({required String submissionId, required String commentId}) async {
    // Retrieve a commment tree
    CommentTree commentTree = await CommentTree.create(reddit: this, submissionId: submissionId, commentId: commentId);
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
}
