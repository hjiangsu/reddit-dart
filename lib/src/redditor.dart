part of 'reddit.dart';

/// Redditor class used by Reddit library
///
/// This class should not be called directly. Rather, this class should be returned when using the Reddit library
class Redditor {
  late Reddit _reddit;

  dynamic _information;

  Map<String, dynamic> submissionListingInformation = {
    "after": null,
    "type": null,
  };

  Redditor._create({required Reddit reddit}) {
    _reddit = reddit;
  }

  /// Factory function to generate the Redditor instance
  static Future<Redditor> create({required Reddit reddit, String? username, Map<String, dynamic>? information}) async {
    Redditor redditorInstance = Redditor._create(reddit: reddit);

    // Do initialization that requires async
    await redditorInstance._initialize(username: username, information: information);

    // Return the fully initialized object
    return redditorInstance;
  }

  /// Initialization function for Redditor class
  _initialize({String? username, Map<String, dynamic>? information}) async {
    Map<String, dynamic> response;
    if (information != null) {
      _information = information;
    } else if (username != null) {
      response = await _reddit.request(method: "GET", endpoint: "/user/$username/about");
      Map<String, dynamic> redditorData = parseRedditor(response);
      _information = redditorData;
    } else {
      response = await _reddit.request(method: "GET", endpoint: "/api/v1/me");
      _information = response;
    }
  }

  preferences() async {
    // Can only be retrieved if there is an authenticated user
    if (_reddit.authorization?.isUserAuthenticated == false) throw Exception("Cannot retrieve preferences for non-authenticated users");

    Map<String, dynamic> preferencesResponse = await _reddit.request(
      method: "GET",
      endpoint: "/api/v1/me/prefs",
    );
    return preferencesResponse;
  }

  /// Retrieves the trophies associated with the current redditor instance
  /// If the current redditor instance is the logged in user, it will retrieve the user's trophies
  ///
  /// If the redditor instance is NOT the logged in user, it will retrieve the redditor's trophies
  ///
  /// This essentially acts like the following endpoints: /api/v1/me/trophies, /api/v1/user/username/trophies
  trophies() async {
    Map<String, dynamic> trophiesResponse = {};

    // Check to see if we have information for the given instance
    if (_information == null) throw Exception("No information provided for the given instance");

    // Grab username from information
    String username = _information["name"];

    // Retrieve the trophies of the given username
    trophiesResponse = await _reddit.request(
      method: "GET",
      endpoint: "/api/v1/user/$username/trophies",
    );

    List<dynamic> trophiesList = parseTrophyList(trophiesResponse);

    return trophiesList;
  }

  subscriptions() async {
    String? after;
    List<dynamic> subredditsResponse = [];
    List<Subreddit> subreddits = [];

    if (_reddit.authorization?.isUserAuthenticated != true) {
      throw Exception("There is not currently logged in user. A user session must be active to obtain subscription information");
    }

    do {
      Map<String, dynamic> _params = {"after": after, "limit": 100};

      Map<String, dynamic> subscriptionsResponse = await _reddit.request(
        method: "GET",
        endpoint: "/subreddits/mine/subscriber",
        params: _params,
      );

      Map<String, dynamic> subredditListing = parseListing(subscriptionsResponse);
      subredditsResponse.addAll(subredditListing["children"]);

      after = subredditListing["after"];
    } while (after != null);

    // Create Subreddit instances from the response data
    for (dynamic _subreddit in subredditsResponse) {
      Map<String, dynamic> subredditData = parseSubreddit(_subreddit);

      Subreddit subreddit = await Subreddit.create(reddit: _reddit, information: subredditData);
      subreddits.add(subreddit);
    }

    return subreddits;
  }

  submissions() async {
    if (_information == null) return;
    String username = _information["name"];

    Map<String, dynamic> submissionResponse = await _reddit.request(method: "GET", endpoint: "/user/$username/submitted");
    Map<String, dynamic> submissionListing = parseListing(submissionResponse);
    List<dynamic> submissionsList = parseSubmissionListing(submissionListing);

    List<Submission> submissions = [];
    for (Map<String, dynamic> submission in submissionsList) {
      submissions.add(await Submission.create(reddit: _reddit, information: submission));
    }

    // Set internal variables
    submissionListingInformation["after"] = submissionListing["after"];

    return submissions;
  }

  moreSubmissions() async {
    if (_information == null) return;
    if (submissionListingInformation["after"] == null) return <Submission>[];
    String username = _information["name"];

    Map<String, dynamic> params = {"after": submissionListingInformation["after"]};

    Map<String, dynamic> submissionResponse = await _reddit.request(
      method: "GET",
      endpoint: "/user/$username/submitted",
      params: params,
    );
    Map<String, dynamic> submissionListing = parseListing(submissionResponse);
    List<dynamic> submissionsList = parseSubmissionListing(submissionListing);

    List<Submission> submissions = [];
    for (Map<String, dynamic> submission in submissionsList) {
      submissions.add(await Submission.create(reddit: _reddit, information: submission));
    }

    // Set internal variables
    submissionListingInformation["after"] = submissionListing["after"];

    return submissions;
  }

  Map<String, dynamic>? get information => _information;
}
