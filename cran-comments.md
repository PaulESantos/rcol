## Submission

First submission of rcolapi 0.0.2 under this package name.
The project was renamed from rcol to avoid a collision with the unrelated
archived CRAN package rcol. This submission is not a takeover of that package.

## Test environments

* Local Windows, R 4.6.1.
* No win-builder, Linux or macOS results are claimed for this release.

## R CMD check results

R CMD check --as-cran on Windows 11, R 4.6.1, UTF-8 locale:
0 errors, 0 warnings, 0 notes (2026-11-22).

After this check, repository and website URLs were updated to rcolapi. The
source archive and vignettes were rebuilt successfully; the complete check
has not yet been repeated for this URL-only update.

The check included installation, examples, unit tests, both vignettes,
vignette rebuilding, and PDF/HTML manuals. The local run disabled the
incoming feasibility checks via _R_CHECK_CRAN_INCOMING_=false and
_R_CHECK_CRAN_INCOMING_REMOTE_=false after the remote check stopped responding.
Remote incoming feasibility and checks on another platform remain outstanding.

The source archive is cran-check/rcolapi_0.0.2.tar.gz; the local log is
cran-check/rcolapi.Rcheck/00check.log. Neither the logs nor the check script
is bundled in the source package.

## Internet access

Unit tests do not require Internet access. Live integration tests are opt-in
via RCOL_LIVE_TESTS=true and are skipped on CRAN. Examples that query the API
are guarded by interactive(); offline examples run normally. Both vignettes
build without API calls.

## URL checks

The link checker reached all but two remote services on 2026-11-22:
https://api.checklistbank.org and https://www.catalogueoflife.org timed out.
These service URLs must be rechecked before submission.

## Method references

The package is a client for the ChecklistBank API, not an implementation of a
new statistical method. The Description links to the service documentation.
