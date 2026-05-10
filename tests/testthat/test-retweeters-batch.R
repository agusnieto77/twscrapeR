test_that("tweet IDs are extracted from supported inputs", {
  extract_tweet_ids <- twscrapeR_test_fn(".extract_tweet_ids")

  expect_identical(extract_tweet_ids(c(123, 456)), c("123", "456"))
  expect_identical(extract_tweet_ids(data.frame(tweet_id = c("a", "b"))), c("a", "b"))
  expect_identical(extract_tweet_ids(data.frame(id = c("x", "y"))), c("x", "y"))

  tweet <- structure(list(id = "999"), class = c("twscraper_tweet", "list"))
  expect_identical(extract_tweet_ids(tweet), "999")

  tweets <- list(list(id = "1"), list(id = 2), "3")
  expect_identical(extract_tweet_ids(tweets), c("1", "2", "3"))
})

test_that("tweet ID extraction rejects unsupported data frames", {
  extract_tweet_ids <- twscrapeR_test_fn(".extract_tweet_ids")

  expect_error(
    extract_tweet_ids(data.frame(other = "value")),
    "columna 'tweet_id' o 'id'"
  )
})

test_that("to_dataframe preserves source tweet ID for batch retweeters", {
  to_dataframe_fn <- twscrapeR_test_fn("to_dataframe")

  users <- list(
    list(id = "u1", username = "one", displayname = "One", description = "", followers_count = 1,
         following_count = 2, tweets_count = 3, verified = FALSE, created = "", location = "",
         url = "", profile_image_url = "", source_tweet_id = "t1"),
    list(id = "u2", username = "two", displayname = "Two", description = "", followers_count = 4,
         following_count = 5, tweets_count = 6, verified = TRUE, created = "", location = "",
         url = "", profile_image_url = "", source_tweet_id = "t2")
  )
  class(users) <- c("twscraper_users", "list")

  df <- to_dataframe_fn(users)

  expect_true("source_tweet_id" %in% names(df))
  expect_identical(as.character(df$source_tweet_id), c("t1", "t2"))
})
