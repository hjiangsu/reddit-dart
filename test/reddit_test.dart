import 'package:flutter_test/flutter_test.dart';

import 'package:reddit/reddit.dart';
import 'package:reddit/src/comment.dart';

// Fill these out before running any tests!
const clientId = "";
const userAgent = "";
const callbackURL = "";
const refreshToken = "";
const accessToken = "";

void main() {
  test('authorization works with clientId, clientSecret, and userAgent', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    await reddit.authorize();

    print(reddit.authorization!.isInitialized);
  });

  test('can retrieve subreddit information from a subreddit', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Subreddit subreddit = await reddit.subreddit("apple");
    print(subreddit.information!["display_name"]);
  });

  test('can retrieve submission information from a subreddit - hot', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Subreddit subreddit = await reddit.subreddit("apple");
    List<Submission> submissions = await subreddit.hot();

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }
  });

  test('can retrieve submission information from a subreddit - new', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Subreddit subreddit = await reddit.subreddit("apple");
    List<Submission> submissions = await subreddit.newest();

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }
  });

  test('can retrieve submission information from a subreddit - top (now)', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Subreddit subreddit = await reddit.subreddit("apple");
    List<Submission> submissions = await subreddit.top("hour");

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }
  });

  test('can retrieve submission information from a subreddit - top (today)', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Subreddit subreddit = await reddit.subreddit("apple");
    List<Submission> submissions = await subreddit.top("day");

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }
  });

  test('can retrieve submission information from a subreddit - top (week)', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Subreddit subreddit = await reddit.subreddit("apple");
    List<Submission> submissions = await subreddit.top("week");

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }
  });

  test('can retrieve submission information from a subreddit - top (month)', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Subreddit subreddit = await reddit.subreddit("apple");
    List<Submission> submissions = await subreddit.top("month");

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }
  });

  test('can retrieve submission information from a subreddit - top (year)', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Subreddit subreddit = await reddit.subreddit("apple");
    List<Submission> submissions = await subreddit.top("year");

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }
  });

  test('can retrieve submission information from a subreddit - top (all)', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Subreddit subreddit = await reddit.subreddit("apple");
    List<Submission> submissions = await subreddit.top("all");

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }
  });

  test('can retrieve more submissions from a subreddit - hot', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Subreddit subreddit = await reddit.subreddit("apple");
    List<Submission> submissions = await subreddit.hot();

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }

    submissions = await subreddit.more();

    print("");

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }
  });

  test('can retrieve submission information from a submission', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    dynamic result = await reddit.submission("5or86n");
    print(result.information["title"]);
  });

  test('can retrieve submission comments from a submission', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Submission submission = await reddit.submission("5or86n");
    List<Comment> comments = submission.commentTree?.comments ?? [];

    for (Comment comment in comments) {
      print(comment.information["body"]);
    }
  });

  test('can retrieve more top-level comments from a submission', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Submission submission = await reddit.submission("5or86n");
    List<Comment> comments = submission.commentTree?.comments ?? [];
    comments = await submission.commentTree?.more();

    for (Comment comment in comments) {
      print(comment.information["body"]);
    }
  });

  test('can retrieve replies from an arbitrary comment', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    CommentTree commentTree = await reddit.commentTree(submissionId: "5or86n", commentId: "dcleoq1");
    List<Comment> comments = commentTree.comments ?? [];

    for (Comment comment in comments) {
      print(comment.information["body"]);
    }
  });

  test('can retrieve front page information from a type - best', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Front front = await reddit.front("best");
    List<Submission> submissions = await front.hot();

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }

    submissions = await front.newest();

    print("");

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }

    submissions = await front.rising();

    print("");

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }

    submissions = await front.top("day");

    print("");

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }
  });

  test('can retrieve front page information from a type - all', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Front front = await reddit.front("all");
    List<Submission> submissions = await front.hot();

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }
  });

  test('can retrieve front page information from a type - popular', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Front front = await reddit.front("popular");
    List<Submission> submissions = await front.hot();

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }
  });

  test('can retrieve more front page information from a type - popular', () async {
    final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
    Front front = await reddit.front("popular");
    List<Submission> submissions = await front.hot();

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }

    submissions = await front.more();

    print("");

    for (Submission submission in submissions) {
      print(submission.information["title"]);
    }
  });

  group('authorization', () {
    test('throws error when passing in bad parameters', () async {
      final Reddit reddit = Reddit(clientId: "", clientSecret: "", userAgent: "");
      Authorization? authorization = await reddit.authorize();
      print('is authorized: ${authorization?.isInitialized}');
    });

    test('can authorize with given clientId, clientSecret, and userAgent', () async {
      final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
      Authorization? authorization = await reddit.authorize();
      print('is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');
    });

    test('can re-authorize with given clientId, clientSecret, and userAgent', () async {
      final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
      Authorization? authorization = await reddit.authorize();
      print('initial: is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');

      await authorization?.reauthorize();
      print('re-authorization: is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');
    });

    test('can force manual authorization map', () async {
      final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent);
      Authorization? authorization = await reddit.authorize();
      print('is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');

      Map<String, dynamic> authorizationMap = {
        "access_token": accessToken,
        "token_type": "bearer",
        "device_id": "88fd40ce-b4c7-47f3-9662-1703721dd760",
        "expires_in": 86400,
        "scope": "*",
      };

      await authorization?.setAuthorization(authorizationMap);
      print('is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');
    });

    test('can force user re-authorization', () async {
      final Reddit reddit = Reddit(clientId: clientId, clientSecret: "", userAgent: userAgent, options: {"callbackURL": callbackURL});
      Authorization? authorization = await reddit.authorize();
      print('is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');

      Map<String, dynamic> userRefreshAuthorizationMap = {
        "access_token": accessToken,
        "token_type": "bearer",
        "expires_in": 86400,
        "scope": "*",
        "refresh_token": refreshToken,
      };

      await authorization?.reauthorize(refreshCredentials: userRefreshAuthorizationMap);
      print('is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');
    });
  });
}
