import 'package:dotenv/dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reddit/reddit.dart';

DotEnv env = DotEnv(includePlatformEnvironment: true)..load();

void main() {
  group('me', () {
    test('can obtain information about the current user', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));

      await reddit.authorize();

      Redditor redditor = await reddit.me();
      print(redditor);
    });

    test('throws error when retrieving subreddit subscriptions on a non-user authentication', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));

      await reddit.authorize();

      Redditor redditor = await reddit.me();
      await redditor.subscriptions();
    });

    test('can retrieve subreddit subscriptions from user', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));

      // Re-authorize as a user
      await reddit.authorize();
      Map<String, dynamic> userRefreshAuthorizationMap = {
        "access_token": env['ACCESS_TOKEN']!,
        "token_type": "bearer",
        "expires_in": 86400,
        "scope": "*",
        "refresh_token": env['REFRESH_TOKEN']!,
      };

      await reddit.authorization?.reauthorize(refreshCredentials: userRefreshAuthorizationMap);

      Redditor redditor = await reddit.me();
      List<Subreddit> subreddits = await redditor.subscriptions();

      for (Subreddit subreddit in subreddits) {
        print(subreddit.information!["display_name"]);
      }
    });

    test('can retrieve user preferences', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));

      // Re-authorize as a user
      await reddit.authorize();
      Map<String, dynamic> userRefreshAuthorizationMap = {
        "access_token": env['ACCESS_TOKEN']!,
        "token_type": "bearer",
        "expires_in": 86400,
        "scope": "*",
        "refresh_token": env['REFRESH_TOKEN']!,
      };

      await reddit.authorization?.reauthorize(refreshCredentials: userRefreshAuthorizationMap);

      Redditor redditor = await reddit.me();
      Map<String, dynamic> preferences = await redditor.preferences();
      expect(preferences, isNotNull);
    });

    test('can retrieve user trophies', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));

      // Re-authorize as a user
      await reddit.authorize();
      Map<String, dynamic> userRefreshAuthorizationMap = {
        "access_token": env['ACCESS_TOKEN']!,
        "token_type": "bearer",
        "expires_in": 86400,
        "scope": "*",
        "refresh_token": env['REFRESH_TOKEN']!,
      };

      await reddit.authorization?.reauthorize(refreshCredentials: userRefreshAuthorizationMap);

      Redditor redditor = await reddit.me();
      List<dynamic> trophies = await redditor.trophies();
      expect(trophies, isNotNull);
    });
  });

  group('redditor', () {
    test('obtains information of a redditor from a given username', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));

      await reddit.authorize();

      Redditor redditor = await reddit.redditor(username: "thermoelectricoreos");
      print(redditor.information!["id"]);
    });

    test('can retrieve user trophies', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));
      await reddit.authorize();

      Redditor redditor = await reddit.redditor(username: "reddit");
      List<dynamic> trophies = await redditor.trophies();
      expect(trophies, isNotNull);
    });

    test('can search for user based on a query with nsfw off', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Search search = await reddit.search();
      List<dynamic> searchResults = await search.search(userQuery: "ther");

      for (Redditor redditor in searchResults) {
        print(redditor.information!["name"]);
      }

      searchResults = await search.more();

      print("");

      for (Redditor redditor in searchResults) {
        print(redditor.information!["name"]);
      }
    });

    test('can search for user based on a query with nsfw on', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Search search = await reddit.search();
      List<dynamic> searchResults = await search.search(userQuery: "ther", nsfw: true);

      for (Redditor redditor in searchResults) {
        print(redditor.information!["name"]);
      }

      searchResults = await search.more();

      print("");

      for (Redditor redditor in searchResults) {
        print(redditor.information!["name"]);
      }
    });

    test('can search for user based on a query with increased limits', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Search search = await reddit.search();
      List<dynamic> searchResults = await search.search(userQuery: "ther", limit: 100);

      for (Redditor redditor in searchResults) {
        print(redditor.information!["name"]);
      }

      searchResults = await search.more();

      print("");

      for (Redditor redditor in searchResults) {
        print(redditor.information!["name"]);
      }
    });

    test('can search for user submissions', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Redditor redditor = await reddit.redditor(username: "_Mace_Windu_");

      List<Submission> submissions = await redditor.submissions();

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }
    });

    test('can search for user submissions with more', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Redditor redditor = await reddit.redditor(username: "KeyTension8633");

      List<Submission> submissions = await redditor.submissions();

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }

      submissions = await redditor.moreSubmissions();

      print("");

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }
    });
  });

  group('submission', () {
    test('can retrieve submission information from a subreddit - hot', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Subreddit subreddit = await reddit.subreddit("apple");
      List<Submission> submissions = await subreddit.hot();

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }
    });

    test('can retrieve submission information from a subreddit - new', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Subreddit subreddit = await reddit.subreddit("apple");
      List<Submission> submissions = await subreddit.newest();

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }
    });

    test('can retrieve submission information from a subreddit - top (now)', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Subreddit subreddit = await reddit.subreddit("apple");
      List<Submission> submissions = await subreddit.top("hour");

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }
    });

    test('can retrieve submission information from a subreddit - top (today)', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Subreddit subreddit = await reddit.subreddit("apple");
      List<Submission> submissions = await subreddit.top("day");

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }
    });

    test('can retrieve submission information from a subreddit - top (week)', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Subreddit subreddit = await reddit.subreddit("apple");
      List<Submission> submissions = await subreddit.top("week");

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }
    });

    test('can retrieve submission information from a subreddit - top (month)', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Subreddit subreddit = await reddit.subreddit("apple");
      List<Submission> submissions = await subreddit.top("month");

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }
    });

    test('can retrieve submission information from a subreddit - top (year)', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Subreddit subreddit = await reddit.subreddit("apple");
      List<Submission> submissions = await subreddit.top("year");

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }
    });

    test('can retrieve submission information from a subreddit - top (all)', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Subreddit subreddit = await reddit.subreddit("apple");
      List<Submission> submissions = await subreddit.top("all");

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }
    });

    test('can retrieve more submissions from a subreddit - hot', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
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
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      dynamic result = await reddit.submission("5or86n");
      print(result.information["title"]);
    });

    test('can save a submission when logged in', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));
      Authorization? authorization = await reddit.authorize();

      Map<String, dynamic> userRefreshAuthorizationMap = {
        "access_token": env['ACCESS_TOKEN']!,
        "token_type": "bearer",
        "expires_in": 86400,
        "scope": "*",
        "refresh_token": env['REFRESH_TOKEN']!,
      };

      await authorization?.reauthorize(refreshCredentials: userRefreshAuthorizationMap);

      Submission submission = await reddit.submission("10xznr6");
      print("Saved status: ${submission.information["saved"]}");
      await submission.save();
      print("Saved status: ${submission.information["saved"]}");
    });

    test('can unsave a submission when logged in', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));
      Authorization? authorization = await reddit.authorize();

      Map<String, dynamic> userRefreshAuthorizationMap = {
        "access_token": env['ACCESS_TOKEN']!,
        "token_type": "bearer",
        "expires_in": 86400,
        "scope": "*",
        "refresh_token": env['REFRESH_TOKEN']!,
      };

      await authorization?.reauthorize(refreshCredentials: userRefreshAuthorizationMap);

      Submission submission = await reddit.submission("10xznr6");
      print("Saved status: ${submission.information["saved"]}");
      await submission.unsave();
      print("Saved status: ${submission.information["saved"]}");
    });

    test('can upvote a submission when logged in', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));
      Authorization? authorization = await reddit.authorize();

      Map<String, dynamic> userRefreshAuthorizationMap = {
        "access_token": env['ACCESS_TOKEN']!,
        "token_type": "bearer",
        "expires_in": 86400,
        "scope": "*",
        "refresh_token": env['REFRESH_TOKEN']!,
      };

      await authorization?.reauthorize(refreshCredentials: userRefreshAuthorizationMap);

      Submission submission = await reddit.submission("10xznr6");
      print("Upvote status: ${submission.information["likes"]}");
      await submission.upvote();
      print("Upvote status: ${submission.information["likes"]}");
    });

    test('can downvote a submission when logged in', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));
      Authorization? authorization = await reddit.authorize();

      Map<String, dynamic> userRefreshAuthorizationMap = {
        "access_token": env['ACCESS_TOKEN']!,
        "token_type": "bearer",
        "expires_in": 86400,
        "scope": "*",
        "refresh_token": env['REFRESH_TOKEN']!,
      };

      await authorization?.reauthorize(refreshCredentials: userRefreshAuthorizationMap);

      Submission submission = await reddit.submission("10xznr6");
      print("Upvote status: ${submission.information["likes"]}");
      await submission.downvote();
      print("Upvote status: ${submission.information["likes"]}");
    });
  });

  group('comment', () {
    test('can retrieve submission comments from a submission', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      CommentTree commentTree = await reddit.commentTree(submissionId: "5or86n", subreddit: 'announcements');
      List<Comment> comments = commentTree.comments ?? [];

      for (Comment comment in comments) {
        print(comment.information["body"]);
      }
    });

    test('can retrieve more comments from a comment', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      CommentTree commentTree = await reddit.commentTree(submissionId: "5or86n", subreddit: 'announcements');
      List<Comment> comments = commentTree.comments ?? [];

      await commentTree.more(commentId: "dclg12s"); // [1][0][1]

      for (Comment comment in comments) {
        print(comment.information["body"]);
      }
    });

    test('can retrieve more top-level comments from a submission', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      CommentTree commentTree = await reddit.commentTree(submissionId: "5or86n", subreddit: 'announcements');
      List<Comment> comments = commentTree.comments ?? [];
      comments = await commentTree.more();

      for (Comment comment in comments) {
        print(comment.information["body"]);
      }
    });

    test('can retrieve replies from an arbitrary comment', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      CommentTree commentTree = await reddit.commentTree(submissionId: "5or86n", commentId: "dcleoq1");
      List<Comment> comments = commentTree.comments ?? [];

      for (Comment comment in comments) {
        print(comment.information["body"]);
      }
    });
  });

  group('front', () {
    test('can retrieve default front page information for logged in user', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));
      Authorization? authorization = await reddit.authorize();
      print('is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');

      Map<String, dynamic> userRefreshAuthorizationMap = {
        "access_token": env['ACCESS_TOKEN']!,
        "token_type": "bearer",
        "expires_in": 86400,
        "scope": "*",
        "refresh_token": env['REFRESH_TOKEN']!,
      };

      await authorization?.reauthorize(refreshCredentials: userRefreshAuthorizationMap);

      Front front = await reddit.front("home");
      List<Submission> submissions = await front.best();

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }

      submissions = await front.more();

      print("");

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }
    });

    test('can retrieve front page information from a type - home', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Front front = await reddit.front("home");
      List<Submission> submissions = await front.best();

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }

      submissions = await front.hot();

      print("");

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
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Front front = await reddit.front("all");
      List<Submission> submissions = await front.hot();

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }
    });

    test('can retrieve front page information from a type - popular', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Front front = await reddit.front("popular");
      List<Submission> submissions = await front.hot();

      for (Submission submission in submissions) {
        print(submission.information["title"]);
      }
    });

    test('can retrieve more front page information from a type - popular', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
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
  });

  group('subreddit', () {
    test('can retrieve subreddit information from a subreddit', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Subreddit subreddit = await reddit.subreddit("apple");
      print(subreddit.information!["display_name"]);
    });

    test('can search for subreddit based on a query with nsfw off', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Search search = await reddit.search();
      List<Subreddit> searchResults = await search.search(subredditQuery: "ask");

      for (Subreddit subreddit in searchResults) {
        print(subreddit.information!["title"]);
      }

      searchResults = await search.more();

      print("");

      for (Subreddit subreddit in searchResults) {
        print(subreddit.information!["title"]);
      }
    });

    test('can search for subreddit based on a query with nsfw on', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Search search = await reddit.search();
      List<Subreddit> searchResults = await search.search(subredditQuery: "ask", nsfw: true);

      for (Subreddit subreddit in searchResults) {
        print(subreddit.information!["title"]);
      }

      searchResults = await search.more();

      print("");

      for (Subreddit subreddit in searchResults) {
        print(subreddit.information!["title"]);
      }
    });

    test('can search for subreddit based on a query with increased limits', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Search search = await reddit.search();
      List<Subreddit> searchResults = await search.search(subredditQuery: "ask", limit: 100);

      for (Subreddit subreddit in searchResults) {
        print(subreddit.information!["title"]);
      }

      searchResults = await search.more();

      print("");

      for (Subreddit subreddit in searchResults) {
        print(subreddit.information!["title"]);
      }
    });

    test('throws error when attempting to subscribe to a subreddit without user authorization', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));
      await reddit.authorize();

      Subreddit subreddit = await Subreddit.create(reddit: reddit, subreddit: "apple");
      await subreddit.subscribe();
    });

    test('can subscribe to a subreddit', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));
      Authorization? authorization = await reddit.authorize();

      Map<String, dynamic> userRefreshAuthorizationMap = {
        "access_token": env['ACCESS_TOKEN']!,
        "token_type": "bearer",
        "expires_in": 86400,
        "scope": "*",
        "refresh_token": env['REFRESH_TOKEN']!,
      };

      await authorization?.reauthorize(refreshCredentials: userRefreshAuthorizationMap);

      Subreddit subreddit = await Subreddit.create(reddit: reddit, subreddit: "apple");
      await subreddit.subscribe();
    });

    test('throws error when attempting to unsubscribe from a subreddit without user authorization', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));
      await reddit.authorize();

      Subreddit subreddit = await Subreddit.create(reddit: reddit, subreddit: "apple");
      await subreddit.unsubscribe();
    });

    test('can unsubscribe from a subreddit', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));
      Authorization? authorization = await reddit.authorize();

      Map<String, dynamic> userRefreshAuthorizationMap = {
        "access_token": env['ACCESS_TOKEN']!,
        "token_type": "bearer",
        "expires_in": 86400,
        "scope": "*",
        "refresh_token": env['REFRESH_TOKEN']!,
      };

      await authorization?.reauthorize(refreshCredentials: userRefreshAuthorizationMap);

      Subreddit subreddit = await Subreddit.create(reddit: reddit, subreddit: "apple");
      await subreddit.unsubscribe();
    });
  });

  group('authorization', () {
    test('throws error when passing in bad parameters', () async {
      final Reddit reddit = Reddit(clientId: "", clientSecret: "", userAgent: "");
      Authorization? authorization = await reddit.authorize();
      print('is authorized: ${authorization?.isInitialized}');
    });

    test('can authorize with given clientId, clientSecret, and userAgent', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Authorization? authorization = await reddit.authorize();
      print('is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');
    });

    test('can re-authorize with given clientId, clientSecret, and userAgent', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Authorization? authorization = await reddit.authorize();
      print('initial: is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');

      await authorization?.reauthorize();
      print('re-authorization: is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');
    });

    test('can force manual authorization map', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!);
      Authorization? authorization = await reddit.authorize();
      print('is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');

      Map<String, dynamic> authorizationMap = {
        "access_token": env['ACCESS_TOKEN']!,
        "token_type": "bearer",
        "device_id": "88fd40ce-b4c7-47f3-9662-1703721dd760",
        "expires_in": 86400,
        "scope": "*",
      };

      await authorization?.setAuthorization(authorizationMap);
      print('is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');
    });

    test('can force user re-authorization', () async {
      final Reddit reddit = Reddit(clientId: env['CLIENT_ID']!, clientSecret: "", userAgent: env['USER_AGENT']!, options: RedditOptions(callbackURL: env['CALLBACK_URL']!));
      Authorization? authorization = await reddit.authorize();
      print('is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');

      Map<String, dynamic> userRefreshAuthorizationMap = {
        "access_token": env['ACCESS_TOKEN']!,
        "token_type": "bearer",
        "expires_in": 86400,
        "scope": "*",
        "refresh_token": env['REFRESH_TOKEN']!,
      };

      await authorization?.reauthorize(refreshCredentials: userRefreshAuthorizationMap);
      print('is authorized: ${authorization?.isInitialized} | authorization: ${authorization?.authorizationInformation}');
    });
  });
}
