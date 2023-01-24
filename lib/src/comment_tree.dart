part of 'reddit.dart';

/// CommentTree class used by Reddit library.
///
/// This class should not be called directly. Rather, this class should be returned when using the Reddit library.
class CommentTree {
  late Reddit _reddit;

  String? _submissionId;

  // List of comment information
  List<Comment>? comments;
  List<dynamic>? moreComments;

  CommentTree._create({required Reddit reddit, String? submissionId}) {
    _reddit = reddit;
    _submissionId = submissionId;
  }

  /// Factory function to generate the CommentForest instance
  static Future<CommentTree> create({required Reddit reddit, String? submissionId, String? subreddit, String? commentId, String? sort}) async {
    CommentTree commentTreeInstance = CommentTree._create(reddit: reddit, submissionId: submissionId);

    if (submissionId != null && subreddit != null) {
      // Do initialization that requires async
      await commentTreeInstance._initializeFromSubmission(submissionId: submissionId, subreddit: subreddit, sort: sort);
    } else if (submissionId != null && commentId != null) {
      await commentTreeInstance._initializeFromComment(submissionId: submissionId, commentId: commentId, sort: sort);
    }

    // Return the fully initialized object
    return commentTreeInstance;
  }

  /// Initialization function for CommentTree class
  _initializeFromSubmission({required String submissionId, required String subreddit, String? sort}) async {
    List<dynamic> commentsResponse = await _reddit.request(
      method: "GET",
      endpoint: "/r/$subreddit/comments/$submissionId",
      params: {"article": submissionId, "depth": 10, "limit": 100, "showmore": true, "sort": sort ?? "top"},
    );

    Map<String, dynamic> commentListing = parseListing(commentsResponse[1]);
    Map<String, dynamic> commentsMap = parseCommentListing(commentListing: commentListing);

    try {
      moreComments = commentsMap['more']["data"]["children"];
    } catch (err) {}

    comments = commentsMap['comments'];
  }

  _initializeFromComment({required String submissionId, required String commentId, String? sort}) async {
    Map<String, dynamic> commentsRawResponse = await _reddit.request(
      method: "POST",
      endpoint: "/api/morechildren",
      params: {
        "link_id": "t3_$submissionId",
        "children": commentId,
        "api_type": "json",
        "limit_children": false,
        "sort": sort ?? "top",
      },
    );

    List<dynamic> commentResponse = commentsRawResponse["json"]["data"]["things"];

    // Convert this to a format that we can parse
    Map<String, dynamic> commentListing = {
      "children": commentResponse,
    };

    Map<String, dynamic> commentsMap = parseCommentListing(commentListing: commentListing);

    // Generate the tree structure now
    Comment parentComment = commentsMap["comments"].firstWhere((Comment comment) => comment.information["id"] == commentId);

    Map<String, dynamic> commentTree = {"t1_$commentId": parentComment};

    for (int i = 0; i < commentsMap["comments"].length; i++) {
      commentTree["t1_${commentsMap["comments"][i].information["id"]}"] = commentsMap["comments"][i];
      commentTree[commentsMap["comments"][i].information["parent_id"]]?.replies.add(commentTree["t1_${commentsMap["comments"][i].information["id"]}"]);
    }

    // try {
    //   String? moreCommentsParentId = commentsMap['more']["data"]["parent_id"]?.substring(3);
    //   _moreComments = commentsMap['more']["data"]["children"] ?? [];

    //   if (moreCommentsParentId != null) {
    //     // fetch the continue thread links
    //     List<dynamic> commentsResponse = await _reddit.request(
    //       method: "GET",
    //       endpoint: "/r/$subreddit/comments/$submissionId//$moreCommentsParentId",
    //       params: {"article": submissionId, "depth": 10, "limit": 100, "showmore": true, "sort": "top"},
    //     );
    //     Map<String, dynamic> moreCommentListing = await parseListing(commentsResponse[1]);
    //     Map<String, dynamic> moreCommentsMap = parseCommentListing(commentListing: moreCommentListing);
    //     print(moreCommentsMap);
    //   }
    // } catch (err) {}
    comments = [commentTree["t1_$commentId"]];
    return comments;
  }

  // Get more top level comments. This only works if the CommentTree was initialized from a Submission.
  // @todo: Make this work for any type of commentTree
  more() async {
    if (moreComments == null || moreComments!.isEmpty) return;

    // Get a subset of the children to fetch, fetch 50 more top level comments at a time
    List<dynamic> childrenToFetch = moreComments!.take(50).toList();

    for (String commentId in childrenToFetch) {
      moreComments!.removeWhere((element) => element == commentId);
    }

    Map<String, dynamic> commentsRawResponse = await _reddit.request(
      method: "GET",
      endpoint: "/api/morechildren",
      params: {
        "link_id": "t3_$_submissionId",
        "children": childrenToFetch.join(","),
        "api_type": "json",
      },
    );

    List<dynamic> commentResponse = commentsRawResponse["json"]["data"]["things"];

    // Convert this to a format that we can parse
    Map<String, dynamic> commentListing = {
      "children": commentResponse,
    };

    Map<String, dynamic> commentsMap = parseCommentListing(commentListing: commentListing);

    comments!.addAll(commentsMap["comments"]);
    return comments;
  }
}
