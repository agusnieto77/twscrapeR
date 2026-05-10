# twscrapeR NEWS

## twscrapeR 0.1.2

Quality and maintenance release after validating `v0.1.1` live scraping.

### Added

- Added dry `testthat` coverage for environment credential helpers, Python string escaping, tweet ID extraction, and batch retweeters conversion.
- Added GitHub Actions CI to run dry R tests on push and pull request without requiring secrets or live X/Twitter access.
- Added `NEWS.md` and `docs/RELEASE.md` so release history and the `.9000` development workflow are explicit.

### Fixed

- Startup messages now show the installed package version instead of a hardcoded version.
- Python string escaping no longer over-escapes newline and carriage-return characters.

### Maintenance

- Kept the XClientTransaction monkeypatch tracker open because upstream `twscrape` fixes are still unreleased.

## twscrapeR 0.1.1

Maintenance release focused on making live scraping work reliably after changes in X/Twitter's web bundles.

### Fixed

- Restored real tweet retrieval for `twscrape 0.17.0` by applying a runtime compatibility patch for the `x-client-transaction-id` parser used by `twscrape`.
- Replaced the hardcoded startup version with the installed package version.
- Corrected Python string escaping for newline and carriage-return characters.

### Added

- Added `add_account_from_env()` to load credentials from `.Renviron` or environment variables using `TWS_*` names.
- Added support for separate `TWS_AUTH_TOKEN` and `TWS_CT0` variables, with automatic cookie-string construction.
- Added `get_retweeters_batch()` for retrieving retweeters across multiple tweets while preserving `source_tweet_id`.
- Added dry `testthat` coverage for credential helpers, tweet ID extraction, retweeters batch conversion, and string escaping.
- Added GitHub Actions CI for dry R tests.

### Documentation

- Documented rate limiting, multiple accounts, the `No account available for queue` message, and the `IndexError: list index out of range` upstream `twscrape` failure mode.

## twscrapeR 0.1.0

Initial public release.

### Added

- Guided Python and `twscrape` setup via `setup_twscraper()`.
- Account management with `add_account()`, `list_accounts()`, and `delete_account()`.
- Tweet search, hashtag search, mention search, user timelines, replies, media, followers, following, retweeters, and verified followers.
- Conversion helpers such as `to_dataframe()` and export helpers for CSV/JSON.
- README and quickstart examples for first-time users.
