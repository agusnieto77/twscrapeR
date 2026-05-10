test_that("cookies can be read directly from env", {
  cookies_from_env <- twscrapeR_test_fn(".cookies_from_env")

  with_envvars(c(
    TEST_COOKIES = "auth_token=direct; ct0=direct",
    TEST_AUTH_TOKEN = "token",
    TEST_CT0 = "ct0"
  ), {
    expect_identical(cookies_from_env("TEST_"), "auth_token=direct; ct0=direct")
  })
})

test_that("cookies can be composed from token env vars", {
  cookies_from_env <- twscrapeR_test_fn(".cookies_from_env")

  with_envvars(c(
    TEST_COOKIES = NA_character_,
    TEST_AUTH_TOKEN = "token_value",
    TEST_CT0 = "ct0_value"
  ), {
    expect_identical(cookies_from_env("TEST_"), "auth_token=token_value; ct0=ct0_value")
  })
})

test_that("missing cookie env vars fail clearly", {
  cookies_from_env <- twscrapeR_test_fn(".cookies_from_env")

  with_envvars(c(
    TEST_COOKIES = NA_character_,
    TEST_AUTH_TOKEN = "token_value",
    TEST_CT0 = NA_character_
  ), {
    expect_error(cookies_from_env("TEST_"), "Faltan cookies")
  })
})

test_that("account env values are assembled without exposing secrets", {
  account_env_values <- twscrapeR_test_fn(".account_env_values")

  with_envvars(c(
    TEST_USERNAME = "usuario",
    TEST_PASSWORD = "password",
    TEST_EMAIL = "email@example.com",
    TEST_EMAIL_PASSWORD = "email_password",
    TEST_AUTH_TOKEN = "token_value",
    TEST_CT0 = "ct0_value",
    TEST_COOKIES = NA_character_
  ), {
    account <- account_env_values("TEST_")

    expect_identical(account$username, "usuario")
    expect_identical(account$email, "email@example.com")
    expect_identical(account$cookies, "auth_token=token_value; ct0=ct0_value")
  })
})

test_that("Python string literals escape unsafe characters", {
  python_string_literal <- twscrapeR_test_fn(".python_string_literal")

  expect_identical(python_string_literal("simple"), "'simple'")
  expect_identical(python_string_literal("a'b"), "'a\\'b'")
  expect_identical(python_string_literal("a\\b"), "'a\\\\b'")
  expect_identical(python_string_literal("a\nb"), "'a\\nb'")
  expect_error(python_string_literal(NA_character_), "string no vacío")
})
