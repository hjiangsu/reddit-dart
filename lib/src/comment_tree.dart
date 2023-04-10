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

    comments = [commentTree["t1_$commentId"]];
    return comments;
  }

  List<int> findCommentById(List<Comment> comments, String id) {
    for (int i = 0; i < comments.length; i++) {
      Comment comment = comments[i];
      if (comment.information["id"] == id) {
        // The comment was found at this level of the tree
        return [i];
      } else {
        // Look for the comment in the replies
        List<int> indexes = findCommentById(comment.replies, id);
        if (indexes.isNotEmpty) {
          // The comment was found in the replies
          indexes.insert(0, i);
          return indexes;
        }
      }
    }
    // The comment was not found
    return [];
  }

  // This function will handle fetching more comments from either the top submission, or any replies
  more({String? commentId, String? sort}) async {
    if (commentId != null) {
      // If a commentId is passed in, then we are attempting to fetch more replies from that comment
      // Run a fetch query using the commentId, and then replace the existing comment with the new one
      Map<String, dynamic> commentsRawResponse = await _reddit.request(
        method: "POST",
        endpoint: "/api/morechildren",
        params: {
          "link_id": "t3_$_submissionId",
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

      Comment fetchedComment = commentTree["t1_$commentId"];

      // Find the indexes which allow us to traverse to the correct comment to be replaced
      List<int> indexes = findCommentById(comments ?? [], commentId);

      if (indexes.isNotEmpty) {
        // Traverse the indexes and update the comment
        Comment? parentComment;
        Comment commentToUpdate = comments![indexes[0]];

        for (int i = 1; i < indexes.length; i++) {
          parentComment = commentToUpdate;
          commentToUpdate = commentToUpdate.replies[indexes[i]];
        }

        // Replace the old comment with the new one
        int lastIndex = indexes.last;

        if (indexes.length == 1) {
          comments![lastIndex] = fetchedComment;
        } else {
          parentComment!.replies[lastIndex] = fetchedComment;
        }
      } else {
        throw Exception("Unable to replace comment as it was not found in the tree");
      }
    } else {
      // Otherwise, let's fetch more comments from the submission
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
    }

    return comments;
  }
}
