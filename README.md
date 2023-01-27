# DRAPI - Dart Reddit API Library
An unofficial Reddit library developed in Dart. This project is currently under heavy development and is ***NOT*** yet suitable for production. Use at your own risk.

## Getting Started
A reddit application must be registered in order to use this library. Check their site for more information regarding how to set up an application with Reddit.

To generate a Reddit instance, the following parameters are required: `clientId`, `clientSecret`, and `userAgent`.
```dart
final Reddit reddit = Reddit(clientId: "client", clientSecret: "secret", userAgent: "agent");
```

With the reddit instance, you can perform basic actions on subreddits, submissions, and comments.
```dart
// Access a subreddit's information
reddit.subreddit("apple").information["display_name"];
reddit.subreddit("apple").information["subscribers"];

// Access the listings/submissions for a given subreddit
reddit.subreddit("apple").hot();
reddit.subreddit("apple").newest();
reddit.subreddit("apple").rising();
reddit.subreddit("apple").top("month");

// Access information for a given submission
reddit.submission("5or86n").information["title"];
reddit.submission("5or86n").information["permalink"];

// Access a given home page's submissions
reddit.front("popular").hot();
reddit.front("popular").newest();
reddit.front("popular").rising();
```

## Implemented API endpoints
The following section describes all the endpoints that are currently implemented. Note that for the implemented endpoints, not all available parameters may be present.

The implemented endpoints are categorized by oauth scope: [https://www.reddit.com/dev/api/oauth](reference)

### auth
- `/api/v1/access_token`

### identity
- `/api/v1/me`

### mysubreddits
- `/subreddits/mine/subscriber`

### read
- `/api/morechildren`
- `/best`
- `/by_id/names` - this is only for retrieving specific submissions
- `/r/subreddit/about`
- `[/r/subreddit]/hot`
- `[/r/subreddit]/new`
- `[/r/subreddit]/rising`
- `[/r/subreddit]/top`
- `[/r/subreddit]/comments/article`
- `/user/username/about`



