part of 'reddit.dart';

/// CommentTree class used by Reddit library.
///
/// This class should not be called directly. Rather, this class should be returned when using the Reddit library.
class CommentTree {
  late Reddit _reddit;

  // List of comment information
  List<Comment>? comments;
  List<dynamic>? moreComments;

  CommentTree._create({required Reddit reddit}) {
    _reddit = reddit;
  }

  /// Factory function to generate the CommentForest instance
  static Future<CommentTree> create({required Reddit reddit, String? submissionId, String? subreddit, String? sort}) async {
    CommentTree commentTreeInstance = CommentTree._create(reddit: reddit);

    if (submissionId != null && subreddit != null) {
      // Do initialization that requires async
      await commentTreeInstance._initializeFromSubmission(submissionId: submissionId, subreddit: subreddit, sort: sort);
    }

    // if (submissionId != null && subreddit != null) {
    //   // Do initialization that requires async
    //   await commentForestInstance._initializeFromSubmission(submissionId: submissionId, subreddit: subreddit);
    // } else if (submissionId != null && commentId != null) {
    //   await commentForestInstance._initializeFromComment(submissionId: submissionId, commentId: commentId);
    // }

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

  // _initializeFromComment({required String submissionId, required String commentId}) async {
  //   Map<String, dynamic> commentsRawResponse = await _reddit.request(
  //     method: "POST",
  //     endpoint: "/api/morechildren",
  //     params: {
  //       "link_id": "t3_$submissionId",
  //       "children": commentId,
  //       "api_type": "json",
  //       // "depth": 10,
  //       "limit_children": false,
  //       "sort": "top",
  //     },
  //   );

  //   List<dynamic> commentResponse = commentsRawResponse["json"]["data"]["things"];
  //   String? subreddit;

  //   // Convert this to a format that we can parse
  //   Map<String, dynamic> commentListing = {
  //     "children": commentResponse,
  //   };

  //   Map<String, dynamic> commentsMap = parseCommentListing(commentListing: commentListing);

  //   // generate the tree structure now
  //   Comment parentComment = commentsMap["comments"].firstWhere((comment) => comment.data["id"] == commentId);
  //   subreddit = parentComment.data["subreddit"];

  //   Map<String, dynamic> commentTree = {"t1_$commentId": parentComment};

  //   for (var i = 0; i < commentsMap["comments"].length; i++) {
  //     commentTree["t1_${commentsMap["comments"][i].data["id"]}"] = commentsMap["comments"][i];
  //     commentTree[commentsMap["comments"][i].data["parent_id"]]?.replies.add(commentTree["t1_${commentsMap["comments"][i].data["id"]}"]);
  //   }

  //   try {
  //     String? moreCommentsParentId = commentsMap['more']["data"]["parent_id"]?.substring(3);
  //     _moreComments = commentsMap['more']["data"]["children"] ?? [];

  //     if (moreCommentsParentId != null) {
  //       // fetch the continue thread links
  //       List<dynamic> commentsResponse = await _reddit.request(
  //         method: "GET",
  //         endpoint: "/r/$subreddit/comments/$submissionId//$moreCommentsParentId",
  //         params: {"article": submissionId, "depth": 10, "limit": 100, "showmore": true, "sort": "top"},
  //       );
  //       Map<String, dynamic> moreCommentListing = await parseListing(commentsResponse[1]);
  //       Map<String, dynamic> moreCommentsMap = parseCommentListing(commentListing: moreCommentListing);
  //       print(moreCommentsMap);
  //     }
  //   } catch (err) {}
  //   _comments = [commentTree["t1_$commentId"]];
  //   return _comments;
  // }

  // // Get more top level comments
  // more() async {
  //   if (_moreComments == null || _moreComments!.length == 0) return;

  //   // Get the parent_id
  //   String linkId = _comments!.first.data["parent_id"];

  //   // Get a subset of the children to fetch
  //   List<dynamic> childrenToFetch = _moreComments!.take(50).toList();

  //   print(_moreComments!.length);
  //   childrenToFetch.forEach((commentId) {
  //     _moreComments!.removeWhere((element) => element == commentId);
  //   });
  //   print(_moreComments!.length);

  //   Map<String, dynamic> commentsRawResponse = await _reddit.request(
  //     method: "GET",
  //     endpoint: "/api/morechildren",
  //     params: {
  //       "link_id": linkId,
  //       "children": childrenToFetch.join(","),
  //       "api_type": "json",
  //     },
  //   );

  //   List<dynamic> commentResponse = commentsRawResponse["json"]["data"]["things"];

  //   // Convert this to a format that we can parse
  //   Map<String, dynamic> commentListing = {
  //     "children": commentResponse,
  //   };

  //   Map<String, dynamic> commentsMap = parseCommentListing(commentListing: commentListing);

  //   _comments!.addAll(commentsMap["comments"]);
  //   return _comments;
  // }

  // List<Comment>? get comments => _comments;
  // List<dynamic>? get children => _moreComments;
}
