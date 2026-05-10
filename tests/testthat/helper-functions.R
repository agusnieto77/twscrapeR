twscrapeR_test_fn <- function(name) {
  if (exists(name, mode = "function", inherits = TRUE)) {
    return(get(name, mode = "function", inherits = TRUE))
  }

  getFromNamespace(name, "twscrapeR")
}

with_envvars <- function(values, code) {
  vars <- names(values)
  old <- Sys.getenv(vars, unset = NA_character_)

  on.exit({
    for (var in vars) {
      if (is.na(old[[var]])) {
        Sys.unsetenv(var)
      } else {
        do.call(Sys.setenv, stats::setNames(as.list(old[[var]]), var))
      }
    }
  }, add = TRUE)

  for (var in vars) {
    if (is.na(values[[var]])) {
      Sys.unsetenv(var)
    } else {
      do.call(Sys.setenv, stats::setNames(as.list(values[[var]]), var))
    }
  }

  force(code)
}
