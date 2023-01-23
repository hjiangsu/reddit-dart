import 'package:flutter_test/flutter_test.dart';

import 'package:reddit/reddit.dart';

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
}
