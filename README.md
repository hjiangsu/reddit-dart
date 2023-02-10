# DRAPI - Dart Reddit API Library
An unofficial Reddit library developed in Dart. This project is currently under heavy development and is **not** yet suitable for production. Use at your own risk.

## Getting Started
A Reddit application must be registered in order to use this library. Check the following [site](https://github.com/reddit-archive/reddit/wiki/OAuth2) for more information regarding how to set up an application with Reddit.

### Authentication

To generate a Reddit instance, the following parameters are required: `clientId`, `clientSecret`, and `userAgent`.
```dart
final Reddit reddit = Reddit(clientId: "client", clientSecret: "secret", userAgent: "agent");
```

If the application is accessing user information (such as authenticating with a given user), then a callback URL must also be specified in order to refresh any user tokens.

```dart
final Reddit reddit = Reddit(
    clientId: "client",
    clientSecret: "secret",
    userAgent: "agent",
    options: {"callbackURL": callbackURL },
);
```

Once the Reddit instance is initialized, you may need to authorize with Reddit's endpoint in order to perform most of the functions listed in the following sections.

You can manually trigger the authorization, but it may not be needed since the library will automatically detect if authorization has been performed, and will perform anonymous authentication if needed.

To authorize with Reddit's endpoints, you can perform the following actions.
```dart
// Performs a manual anonymous authorization with Reddit - this generates the access_token needed for calls to the OAuth endpoints.
reddit.authorize();

// If you already have the auth information, you can manually set the auth information.
// Note that reddit.authorize() must be called at least once in order to set the auth information.
reddit.authorize();
reddit.authorization?.setAuthorization(authorizationInformation);

// Performs user-based authorization given that you already have the refresh_token of the user. 
// Note that reddit.authorize() must be called at least once in order to set the auth information.
reddit.authorize();
reddit.authorization?.reauthorize(refreshCredentials: userRefreshAuthorizationMap);
```

### Accessing Front Pages
In this context, a front page indicates the initial page that a user sees when navigating to Reddit. This includes the user's home feed (if logged in), or the popular/all feed.

Front pages don't contain information regarding the subreddit, since its a combination of submissions from many individual subreddits.

```dart
// Access a given front page's submissions
reddit.front("popular").hot();
reddit.front("popular").newest();
reddit.front("popular").rising();
reddit.front("popular").top("day");

// Other options for front include "best" and "all"
reddit.front("best").hot();
reddit.front("all").hot();

// If using top(), the available options are "hour", "day", "week", "month", "year", and "all"
reddit.front("best").top("hour");
reddit.front("best").top("month");
reddit.front("best").top("all");

// To access more submissions, you can perform the following
reddit.front("best").hot().more();
```

### Accessing Subreddit Information & Submissions
With the reddit instance, you can also access information and submissions from a given subreddit.
```dart
// Access a subreddit's information
reddit.subreddit("apple").information["display_name"];
reddit.subreddit("apple").information["subscribers"];

// Access a subreddit's submissions
reddit.subreddit("apple").hot();
reddit.subreddit("apple").newest();
reddit.subreddit("apple").rising();
reddit.subreddit("apple").top("day");

// The options for submissions are similar to the front page
reddit.subreddit("apple").top("hour");
reddit.subreddit("apple").top("month");
reddit.subreddit("apple").top("all");

// To access more submissions, you can perform the following
reddit.subreddit("apple").hot().more();
```

### Accessing a Submission's Information & Comments
You can access a specific submission's information given that you have the `id` of the submission. When accessing a given submission, you also have access to the submission's comment tree.
```dart
// Access information for a given submission
reddit.submission("5or86n").information["title"];
reddit.submission("5or86n").information["permalink"];
```

If you are logged in as an authorized user, you may perform other user-related actions such as voting and saving submissions.

A submission must not be archived in order to perform voting actions. If a submission is already voted on, and the same voting type is called, it will revert the status of the vote.

If a submission is saved, or unsaved, and the same action is performed on it, it will not affect or modify the saved status of the submission.
```dart
reddit.submission("5or86n").upvote();
// Calling upvote() again on a upvoted submission will cause it to be neutral
reddit.submission("5or86n").upvote();

reddit.submission("5or86n").downvote();
// Calling downvote() again on a downvoted submission will cause it to be neutral
reddit.submission("5or86n").downvote();

reddit.submission("5or86n").save();
reddit.submission("5or86n").unsave();
```

### Redditor Information
If the app has user-authentication, and a user has given access/permissions to the application, you may retrieve information as if you were that user.

#### Accessing Subreddit Subscriptions
You can access a user's subreddit subscriptions using the following functions. Note that you need to have OAuth authentication as the user to perform the following actions.

```dart
// Obtains the currently logged in user's subreddit subscriptions
reddit.me().subscriptions();
```

## Implemented API endpoints
The following section describes all the endpoints that are currently implemented. Note that for the implemented endpoints, not all available parameters may be present.

The implemented endpoints are categorized by oauth scope as described in the Reddit API documentation: [reference](https://www.reddit.com/dev/api/oauth)

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

### save
- `/api/save`
- `/api/unsave`

### vote
- `/api/vote`


## Running Tests
To run tests defined in the `/test` directory, environment variables must first be passed in from a `.env` file otherwise tests may fail.

An example of a `.env` file is shown below (and also in `.example_env file`)
```
CLIENT_ID = clientId
USER_AGENT = example (by /u/example)
CALLBACK_URL = callbackURL
REFRESH_TOKEN = refreshToken
ACCESS_TOKEN = accessToken
```