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

  save() async {
    if (_information == null) return;

    // Get the fullname
    String submissionId = _information!["id"];

    // Check to see if the submission is saved - ignore if already saved
    bool saved = _information?["saved"] ?? false;
    if (saved) return;

    await _reddit.request(
      method: "POST",
      endpoint: "/api/save",
      params: {"id": "t3_$submissionId"},
    );

    // Refetch submission to get updated information
    await _initialize(id: submissionId, fetchComments: false);
  }

  unsave() async {
    if (_information == null) return;

    // Get the fullname
    String submissionId = _information!["id"];

    // Check to see if the submission is saved - ignore if already saved
    bool unsaved = _information?["saved"] == false;
    if (unsaved) return;

    await _reddit.request(
      method: "POST",
      endpoint: "/api/unsave",
      params: {"id": "t3_$submissionId"},
    );

    // Refetch submission to get updated information
    await _initialize(id: submissionId, fetchComments: false);
  }

  upvote() async {
    if (_information == null) return;

    // Check to see if user is authenticated
    if (_reddit.authorization?.isUserAuthenticated == false) return;

    // Check to see if the submission is archived - archived submissions cannot be voted on
    bool archived = _information?["archived"] ?? false;
    if (archived) return;

    // Get the fullname
    String submissionId = _information!["id"];

    // Get the vote status to see if it was already upvoted
    bool upvoted = _information?["likes"] ?? false;

    await _reddit.request(
      method: "POST",
      endpoint: "/api/vote",
      params: {"id": "t3_$submissionId", "dir": upvoted ? 0 : 1},
    );

    // Refetch submission to get updated information
    await _initialize(id: submissionId, fetchComments: false);
  }

  downvote() async {
    if (_information == null) return;

    // Check to see if user is authenticated
    if (_reddit.authorization?.isUserAuthenticated == false) return;

    // Check to see if the submission is archived - archived submissions cannot be voted on
    bool archived = _information?["archived"] ?? false;
    if (archived) return;

    // Get the fullname
    String submissionId = _information!["id"];

    // Get the vote status to see if it was already upvoted
    bool downvoted = _information?["likes"] == false;

    await _reddit.request(
      method: "POST",
      endpoint: "/api/vote",
      params: {"id": "t3_$submissionId", "dir": downvoted ? 0 : -1},
    );

    // Refetch submission to get updated information
    await _initialize(id: submissionId, fetchComments: false);
  }

  Map<String, dynamic> get information => _information ?? {};
}
