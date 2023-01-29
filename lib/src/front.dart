part of 'reddit.dart';

/// Subreddit class used by Reddit library to represent the front page. This includes home, /r/popular, and /r/all.
/// The difference between this class and the Subreddit class is that there are multiple subreddits together.
/// Thus, there is no subreddit information as you would see on a Subreddit class.
///
/// This class should not be called directly. Rather, this class should be returned when using the Reddit library.
class Front {
  late Reddit _reddit;
  late String frontType;

  // Initial submissions from calling the initialization
  List<Submission> initialSubmissions = [];

  // Front submissions and data
  Map<String, dynamic> submissionListingInformation = {
    "after": null,
    "type": null,
  };

  Front._create({required Reddit reddit, required String type}) {
    _reddit = reddit;
    frontType = type;
  }

  /// Factory function to generate the Front instance
  static Future<Front> create({required Reddit reddit, String? type}) async {
    Front frontInstance = Front._create(reddit: reddit, type: type ?? "popular");

    // Do initialization that requires async
    await frontInstance._initialize(type: type);

    // Return the fully initialized object
    return frontInstance;
  }

  /// Initialization function for Front class. Takes in "popular", "home", and "all"
  _initialize({String? type}) async {
    Map<String, dynamic> submissionResponse = {};

    if (type == "home") {
      submissionResponse = await _reddit.request(method: "GET", endpoint: "/best");
    } else {
      submissionResponse = await _reddit.request(method: "GET", endpoint: "/r/$type");
    }

    Map<String, dynamic> submissionListing = parseListing(submissionResponse);
    List<dynamic> submissionsList = parseSubmissionListing(submissionListing);

    List<Submission> submissions = [];
    for (Map<String, dynamic> submission in submissionsList) {
      submissions.add(await Submission.create(reddit: _reddit, information: submission));
    }

    initialSubmissions = submissions;

    // Set internal variables to hold for querying more submissions
    if (type == "home") {
      submissionListingInformation["type"] = "";
    } else {
      submissionListingInformation["type"] = "hot";
    }
    submissionListingInformation["timeframe"] = null;
    submissionListingInformation["after"] = submissionListing["after"];
  }

  /// Obtain the listings categorized by "hot"
  hot() async {
    Map<String, dynamic> submissionResponse = {};

    if (frontType == "home") {
      submissionResponse = await _reddit.request(method: "GET", endpoint: "/hot");
    } else {
      submissionResponse = await _reddit.request(method: "GET", endpoint: "/r/$frontType/hot");
    }

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
    Map<String, dynamic> submissionResponse = {};

    if (frontType == "home") {
      submissionResponse = await _reddit.request(method: "GET", endpoint: "/new");
    } else {
      submissionResponse = await _reddit.request(method: "GET", endpoint: "/r/$frontType/new");
    }

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
    Map<String, dynamic> submissionResponse = {};

    if (frontType == "home") {
      submissionResponse = await _reddit.request(
        method: "GET",
        endpoint: "/top",
        params: {"t": timeframe},
      );
    } else {
      submissionResponse = await _reddit.request(
        method: "GET",
        endpoint: "/r/$frontType/top",
        params: {"t": timeframe},
      );
    }

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
    Map<String, dynamic> submissionResponse = {};

    if (frontType == "home") {
      submissionResponse = await _reddit.request(method: "GET", endpoint: "/rising");
    } else {
      submissionResponse = await _reddit.request(method: "GET", endpoint: "/r/$frontType/rising");
    }

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
    Map<String, dynamic> params = {"after": submissionListingInformation["after"]};

    if (submissionListingInformation["timeframe"] != null) {
      params.putIfAbsent('t', () => submissionListingInformation["timeframe"]);
    }

    Map<String, dynamic> submissionResponse = {};

    if (frontType == "home") {
      submissionResponse = await _reddit.request(
        method: "GET",
        endpoint: submissionListingInformation["type"] != "" ? "/${submissionListingInformation["type"]}" : "/best",
        params: params,
      );
    } else {
      submissionResponse = await _reddit.request(
        method: "GET",
        endpoint: "/r/$frontType/${submissionListingInformation["type"]}",
        params: params,
      );
    }

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
}
