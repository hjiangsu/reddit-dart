import 'package:flutter_test/flutter_test.dart';

import 'package:reddit/reddit.dart';
import 'package:reddit/src/comment.dart';

const clientId = "";
const userAgent = "";

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
}
