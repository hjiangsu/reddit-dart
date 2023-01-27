/// Implemented API functions
///
/// ```
/// /r/subreddit/about
///
/// [/r/subreddit]/hot
/// [/r/subreddit]/new
/// [/r/subreddit]/rising
/// [/r/subreddit]/top
///
///
/// Not yet re-implemented
/// [/r/subreddit]/random
/// [/r/subreddit]/controversial
///
/// [/r/subreddit]/wiki/pages
/// [/r/subreddit]/wiki/page
/// ```

part of 'reddit.dart';

/// Subreddit class used by Reddit library.
///
/// This class should not be called directly. Rather, this class should be returned when using the Reddit library.
class Subreddit {
  late Reddit _reddit;

  // Subreddit information
  Map<String, dynamic>? _information;

  // Subreddit submissions and data
  Map<String, dynamic> submissionListingInformation = {
    "after": null,
    "type": null,
  };
  // String? _after;
  // String? _type;
  // String? _timeframe;
  // List<Submission>? _submissions;

  Subreddit._create({required Reddit reddit}) {
    _reddit = reddit;
  }

  /// Factory function to generate the Subreddit instance
  static Future<Subreddit> create({required Reddit reddit, String? subreddit, Map<String, dynamic>? information}) async {
    Subreddit subredditInstance = Subreddit._create(reddit: reddit);

    // Do initialization that requires async
    await subredditInstance._initialize(subreddit: subreddit, information: information);

    // Return the fully initialized object
    return subredditInstance;
  }

  /// Initialization function for Subreddit class
  _initialize({String? subreddit, Map<String, dynamic>? information}) async {
    if (information != null) {
      _information = information;
    } else if (subreddit != null) {
      Map<String, dynamic> subredditResponse = await _reddit.request(method: "GET", endpoint: "/r/$subreddit/about");
      Map<String, dynamic> subredditData = parseSubreddit(subredditResponse);
      _information = subredditData;
    }
  }

  /// Obtain the listings categorized by "hot"
  hot() async {
    if (_information == null) return;

    Map<String, dynamic> submissionResponse = await _reddit.request(method: "GET", endpoint: "/r/${_information!["display_name"]}/hot");
    Map<String, dynamic> submissionListing = parseListing(submissionResponse);
    List<dynamic> submissionsList = parseSubmissionListing(submissionListing);

    List<Submission> submissions = [];
    for (Map<String, dynamic> submissionInformation in submissionsList) {
      submissions.add(await Submission.create(reddit: _reddit, information: submissionInformation));
    }

    // Set internal variables to hold for querying more submissions
    submissionListingInformation["type"] = "hot";
    submissionListingInformation["timeframe"] = null;
    submissionListingInformation["after"] = submissionListing["after"];

    return submissions;
  }

  /// Obtain the listings categorized by "new"
  newest() async {
    if (_information == null) return;

    Map<String, dynamic> submissionResponse = await _reddit.request(method: "GET", endpoint: "/r/${_information!["display_name"]}/new");
    Map<String, dynamic> submissionListing = parseListing(submissionResponse);
    List<dynamic> submissionsList = parseSubmissionListing(submissionListing);

    List<Submission> submissions = [];
    for (Map<String, dynamic> submissionInformation in submissionsList) {
      submissions.add(await Submission.create(reddit: _reddit, information: submissionInformation));
    }

    // Set internal variables to hold for querying more submissions
    submissionListingInformation["type"] = "new";
    submissionListingInformation["timeframe"] = null;
    submissionListingInformation["after"] = submissionListing["after"];

    return submissions;
  }

  /// Obtain the listings categorized by "top"
  ///
  /// `timeframe` must be one of "hour", "day", "week", "month", "year", "all"
  top(String timeframe) async {
    if (_information == null) return;

    Map<String, dynamic> submissionResponse = await _reddit.request(
      method: "GET",
      endpoint: "/r/${_information!["display_name"]}/top",
      params: {"t": timeframe},
    );

    Map<String, dynamic> submissionListing = parseListing(submissionResponse);
    List<dynamic> submissionsList = parseSubmissionListing(submissionListing);

    List<Submission> submissions = [];
    for (Map<String, dynamic> submissionInformation in submissionsList) {
      submissions.add(await Submission.create(reddit: _reddit, information: submissionInformation));
    }

    // Set internal variables to hold for querying more submissions
    submissionListingInformation["type"] = "top";
    submissionListingInformation["timeframe"] = timeframe;
    submissionListingInformation["after"] = submissionListing["after"];

    return submissions;
  }

  /// Obtain the listings categorized by "rising"
  rising() async {
    if (_information == null) return;

    Map<String, dynamic> submissionResponse = await _reddit.request(method: "GET", endpoint: "/r/${_information!["display_name"]}/rising");
    Map<String, dynamic> submissionListing = parseListing(submissionResponse);
    List<dynamic> submissionsList = parseSubmissionListing(submissionListing);

    List<Submission> submissions = [];
    for (Map<String, dynamic> submissionInformation in submissionsList) {
      submissions.add(await Submission.create(reddit: _reddit, information: submissionInformation));
    }

    // Set internal variables to hold for querying more submissions
    submissionListingInformation["type"] = "rising";
    submissionListingInformation["timeframe"] = null;
    submissionListingInformation["after"] = submissionListing["after"];

    return submissions;
  }

  /// Obtain more submissions with the given type
  more() async {
    if (_information == null) return;

    Map<String, dynamic> params = {"after": submissionListingInformation["after"]};

    if (submissionListingInformation["timeframe"] != null) {
      params.putIfAbsent('t', () => submissionListingInformation["timeframe"]);
    }

    Map<String, dynamic> submissionResponse = await _reddit.request(
      method: "GET",
      endpoint: "/r/${_information!["display_name"]}/${submissionListingInformation["type"]}",
      params: params,
    );

    Map<String, dynamic> submissionListing = parseListing(submissionResponse);
    List<dynamic> submissionsList = parseSubmissionListing(submissionListing);

    List<Submission> submissions = [];
    for (Map<String, dynamic> submissionInformation in submissionsList) {
      submissions.add(await Submission.create(reddit: _reddit, information: submissionInformation));
    }

    // Set internal variables to hold for querying more submissions
    submissionListingInformation["after"] = submissionListing["after"];

    return submissions;
  }

  // /// Obtain a random post from the subreddit
  // random() async {
  //   if (_information == null) return;

  //   // Returns a list where the 0th element is the post information, and the 1st element is the comment
  //   List<dynamic> response = await _reddit.request(method: "GET", endpoint: "/r/${_information!["display_name"]}/random");
  //   Map<String, dynamic> submissionListing = parseListing(response[0]);
  //   // Map<String, dynamic> commentListing = parseListing(response[1]); --> we don't care for the comments since we are only displaying the post

  //   // List<Comment> comments = parseCommentListing(commentsListing);
  //   List<dynamic> submissionsList = parseSubmissionListing(submissionListing);

  //   List<Submission> submissions = [];
  //   for (Map<String, dynamic> submission in submissionsList) {
  //     submissions.add(await Submission.create(reddit: _reddit, information: submission));
  //   }

  //   // Set internal variables
  //   _type = null;
  //   _timeframe = null;
  //   _submissions = submissions;
  //   _after = null;

  //   return _submissions;
  // }

  // /// Obtain the listings categorized by "controversial"
  // ///
  // /// `timeframe` must be one of "hour", "day", "week", "month", "year", "all"
  // controversial(String timeframe) async {
  //   if (_information == null) return;

  //   Map<String, dynamic> submissionResponse = await _reddit.request(
  //     method: "GET",
  //     endpoint: "/r/${_information!["display_name"]}/controversial",
  //     params: {"t": timeframe},
  //   );

  //   Map<String, dynamic> submissionListing = parseListing(submissionResponse);
  //   List<dynamic> submissionsList = parseSubmissionListing(submissionListing);

  //   List<Submission> submissions = [];
  //   for (Map<String, dynamic> submission in submissionsList) {
  //     submissions.add(await Submission.create(reddit: _reddit, information: submission));
  //   }

  //   // Set internal variables
  //   _type = "controversial";
  //   _timeframe = timeframe;
  //   _submissions = submissions;
  //   _after = submissionListing["after"];

  //   return _submissions;
  // }

  // /// Obtain the wiki pages for the subreddit
  // wiki({String? page}) async {
  //   if (_information == null) return;

  //   if (page == null) {
  //     Map<String, dynamic> wikiResponse = await _reddit.request(method: "GET", endpoint: "/r/${_information!["display_name"]}/wiki/pages");
  //     if (!wikiResponse.containsKey('data')) return;

  //     return wikiResponse["data"];
  //   } else {
  //     Map<String, dynamic> wikiResponse = await _reddit.request(method: "GET", endpoint: "/r/${_information!["display_name"]}/wiki/$page");

  //     return wikiResponse["data"];
  //   }
  // }

  Map<String, dynamic>? get information => _information;
}
