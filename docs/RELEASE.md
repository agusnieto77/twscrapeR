# Release workflow

This project uses GitHub releases and keeps `DESCRIPTION` as the package-version source of truth.

## Quick path

1. Confirm `main` is clean and pushed.
2. Set `DESCRIPTION` to the release version, for example `0.1.2`.
3. Commit with `chore(release): bump version to 0.1.2`.
4. Create the GitHub release tag, for example `v0.1.2`.
5. After release, bump `DESCRIPTION` to the next development version, for example `0.1.2.9000`.

## Pre-release checklist

- [ ] `NEWS.md` has an entry for the release.
- [ ] Dry tests pass locally.
- [ ] CI is green on `main`.
- [ ] Live scraping was validated manually when the release affects X/Twitter access.
- [ ] No secrets, account databases, cookies, or `.Renviron` content are committed.

## Commands

```bash
# Inspect current state
git status --short --branch
git log --oneline -5

# Create release after committing the DESCRIPTION bump
gh release create v0.1.2 \
  --target main \
  --title "twscrapeR v0.1.2" \
  --notes-file release-notes.md
```

## Versioning rule

After every public release, `main` should move back to a development version with `.9000`.

Example:

| State | `DESCRIPTION` version |
|-------|------------------------|
| Released tag `v0.1.1` | `0.1.1` |
| Ongoing development after release | `0.1.1.9000` |
| Next release candidate | `0.1.2` |

## Live validation rule

Live validation is manual and local only. It may use `TWS_*` variables from `.Renviron`, but tests and CI must stay dry and must never require secrets.
