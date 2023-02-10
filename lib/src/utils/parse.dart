import 'package:reddit/src/comment.dart';

List<dynamic> parseSubredditListing(Map<String, dynamic> subredditListing) {
  List<dynamic> children = subredditListing["children"];

  List<dynamic> parsedSubreddit = [];

  for (Map<String, dynamic> child in children) {
    if (child["kind"] == "t5") {
      parsedSubreddit.add(parseSubreddit(child));
    }
  }

  return parsedSubreddit;
}

List<dynamic> parseRedditorListing(Map<String, dynamic> redditorListing) {
  List<dynamic> children = redditorListing["children"];

  List<dynamic> parsedRedditor = [];

  for (Map<String, dynamic> child in children) {
    if (child["kind"] == "t2") {
      parsedRedditor.add(parseRedditor(child));
    }
  }

  return parsedRedditor;
}

List<dynamic> parseSubmissionListing(Map<String, dynamic> submissionListing) {
  List<dynamic> children = submissionListing["children"];

  List<dynamic> parsedSubmissions = [];

  for (Map<String, dynamic> child in children) {
    if (child["kind"] == "t3") {
      parsedSubmissions.add(parseSubmission(child));
    }
  }

  return parsedSubmissions;
}

Map<String, dynamic> parseCommentListing({required Map<String, dynamic> commentListing, String? parentId}) {
  List<dynamic> children = commentListing["children"];

  List<Comment> comments = [];
  Map<String, dynamic>? moreComments;

  children.asMap().forEach((index, comment) {
    if (comment["kind"] == "t1") {
      comments.add(Comment(information: comment["data"]));
    } else if (comment["kind"] == "more") {
      moreComments = comment;
    }
  });

  Map<String, dynamic> response = {
    'comments': comments,
    'more': moreComments,
  };

  return response;
}

Map<String, dynamic> parseListing(Map<String, dynamic> data) {
  if (!data.containsKey("data")) throw Exception("Response does not contain any data");
  if (!data.containsKey("kind") && data["kind"] != "Listing") throw Exception("Response does not contain the correct type of data");

  return data["data"];
}

Map<String, dynamic> parseSubreddit(Map<String, dynamic> subredditResponse) {
  if (!subredditResponse.containsKey("data")) throw Exception("Response does not contain any data");
  if (!subredditResponse.containsKey("kind") && subredditResponse["kind"] != "t5") throw Exception("Response does not contain the correct type of data");

  return subredditResponse["data"];
}

Map<String, dynamic> parseSubmission(Map<String, dynamic> submissionResponse) {
  if (!submissionResponse.containsKey("data")) throw Exception("Response does not contain any data");
  if (!submissionResponse.containsKey("kind") && submissionResponse["kind"] != "t3") throw Exception("Response does not contain the correct type of data");

  return submissionResponse["data"];
}

Map<String, dynamic> parseRedditor(Map<String, dynamic> redditorResponse) {
  if (!redditorResponse.containsKey("data")) throw Exception("Response does not contain any data");
  if (!redditorResponse.containsKey("kind") && redditorResponse["kind"] != "t2") throw Exception("Response does not contain the correct type of data");

  return redditorResponse["data"];
}

// From a TrophyList, parse result to normalized format
List<dynamic> parseTrophyList(Map<String, dynamic> data) {
  if (!data.containsKey("data")) throw Exception("Response does not contain any data");
  if (!data.containsKey("kind") && data["kind"] != "TrophyList") throw Exception("Response does not contain the correct type of data");

  List<dynamic> trophyList = data["data"]["trophies"];

  List<dynamic> formattedTrophyList = [];

  for (Map<String, dynamic> trophyResponseMap in trophyList) {
    formattedTrophyList.add(trophyResponseMap["data"]);
  }

  return formattedTrophyList;
}
