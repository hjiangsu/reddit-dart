part of 'reddit.dart';

/// Submission class used by Reddit library.
///
/// This class should not be called directly. Rather, this class should be returned when using the Reddit library.
class Submission {
  late Reddit _reddit;

  // Submission information
  Map<String, dynamic>? _information;

  // Comment information
  CommentTree? commentTree;
  Map<String, dynamic> commentInformation = {
    "limit": 2048,
    "sort": "confidence",
  };

  Submission._create({required Reddit reddit}) {
    _reddit = reddit;
  }

  /// Factory function that generates a Submission instance
  static Future<Submission> create({required Reddit reddit, String? id, Map<String, dynamic>? information, bool? fetchComments}) async {
    Submission submissionInstance = Submission._create(reddit: reddit);

    // Do initialization that requires async
    await submissionInstance._initialize(id: id, information: information, fetchComments: fetchComments ?? false);

    // Return the fully initialized object
    return submissionInstance;
  }

  /// Initialization function for Submission class
  _initialize({String? id, Map<String, dynamic>? information, required bool fetchComments}) async {
    if (information != null) {
      _information = information;
    } else if (id != null) {
      Map<String, dynamic> submissionResponse = await _reddit.request(
        method: "GET",
        endpoint: "/by_id/t3_$id",
        params: {
          "limit": commentInformation["limit"],
          "sort": commentInformation["sort"],
        },
      );
      Map<String, dynamic> submissionListing = parseListing(submissionResponse);
      List<dynamic> submissionsList = parseSubmissionListing(submissionListing);

      _information = submissionsList.first;
    }

    if (fetchComments == true) {
      String submissionId = _information!["id"];
      String subreddit = _information!["subreddit"];
      CommentTree _commentTree = await CommentTree.create(reddit: _reddit, submissionId: submissionId, subreddit: subreddit);
      commentTree = _commentTree;
    }
  }

  Map<String, dynamic> get information => _information ?? {};
}
