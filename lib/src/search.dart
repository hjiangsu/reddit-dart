part of 'reddit.dart';

/// Search class used by Reddit library.
///
/// This class should not be called directly. Rather, this class should be returned when using the Reddit library.
class Search {
  late Reddit _reddit;

  // Search information
  Map<String, dynamic> searchListingInformation = {
    "after": null,
    "query": null,
    "limit": 25,
    "type": null,
  };

  Search._create({required Reddit reddit}) {
    _reddit = reddit;
  }

  /// Factory function that generates a Search instance
  static Future<Search> create({required Reddit reddit}) async {
    Search searchInstance = Search._create(reddit: reddit);

    // Do initialization that requires async
    await searchInstance._initialize();

    // Return the fully initialized object
    return searchInstance;
  }

  /// Initialization function for Submission class
  _initialize() async {}

  /// Performs search for a given subreddit or user
  search({String? subredditQuery, String? userQuery, int? limit, bool? nsfw = false}) async {
    Map<String, dynamic> response;

    if (subredditQuery != null) {
      Map<String, dynamic> params = {
        "q": '"$subredditQuery"',
        "limit": limit ?? "25",
      };

      if (nsfw == true) {
        params.addAll({"include_over_18": '"on"', "search_include_over_18": '"on"'});
      }

      response = await _reddit.request(method: "GET", endpoint: "/subreddits/search", params: params);
      Map<String, dynamic> listing = parseListing(response);
      List<dynamic> subreddits = parseSubredditListing(listing);

      List<Subreddit> subredditsList = [];
      for (Map<String, dynamic> subredditInformation in subreddits) {
        subredditsList.add(await Subreddit.create(reddit: _reddit, information: subredditInformation));
      }

      searchListingInformation["type"] = "subreddit";
      searchListingInformation["after"] = listing["after"];
      searchListingInformation["query"] = subredditQuery;
      searchListingInformation["limit"] = limit ?? 25;
      searchListingInformation["nsfw"] = nsfw;

      return subredditsList;
    } else if (userQuery != null) {
      Map<String, dynamic> params = {
        "q": '"$userQuery"',
        "limit": limit ?? "25",
      };

      if (nsfw == true) {
        params.addAll({"include_over_18": '"on"', "search_include_over_18": '"on"'});
      }

      response = await _reddit.request(method: "GET", endpoint: "/users/search", params: params);
      Map<String, dynamic> listing = parseListing(response);
      List<dynamic> redditors = parseRedditorListing(listing);

      List<Redditor> redditorsList = [];
      for (Map<String, dynamic> redditorInformation in redditors) {
        redditorsList.add(await Redditor.create(reddit: _reddit, information: redditorInformation));
      }

      searchListingInformation["type"] = "user";
      searchListingInformation["after"] = listing["after"];
      searchListingInformation["query"] = userQuery;
      searchListingInformation["limit"] = limit ?? 25;
      searchListingInformation["nsfw"] = nsfw;

      return redditorsList;
    }
  }

  // Continues the search
  more() async {
    if (searchListingInformation["type"] == null) throw Exception("No search type specified");

    Map<String, dynamic> params = {
      "q": '"${searchListingInformation["query"]}"',
      "limit": searchListingInformation["limit"].toString(),
      "after": searchListingInformation["after"],
    };

    if (searchListingInformation["nsfw"] == true) {
      params.addAll({"include_over_18": '"on"', "search_include_over_18": '"on"'});
    }

    if (searchListingInformation["type"] == "subreddit") {
      Map<String, dynamic> response = await _reddit.request(method: "GET", endpoint: "/subreddits/search", params: params);
      Map<String, dynamic> listing = parseListing(response);
      List<dynamic> subreddits = parseSubredditListing(listing);

      List<Subreddit> subredditsList = [];
      for (Map<String, dynamic> subredditInformation in subreddits) {
        subredditsList.add(await Subreddit.create(reddit: _reddit, information: subredditInformation));
      }

      searchListingInformation["after"] = listing["after"];

      return subredditsList;
    } else if (searchListingInformation["type"] == "user") {
      Map<String, dynamic> response = await _reddit.request(method: "GET", endpoint: "/users/search", params: params);
      Map<String, dynamic> listing = parseListing(response);
      List<dynamic> redditors = parseRedditorListing(listing);

      List<Redditor> redditorsList = [];
      for (Map<String, dynamic> redditorInformation in redditors) {
        redditorsList.add(await Redditor.create(reddit: _reddit, information: redditorInformation));
      }

      searchListingInformation["after"] = listing["after"];
      return redditorsList;
    }
  }
}
