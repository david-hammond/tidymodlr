## Release version 1.0.0

I have followed the resubmission instructions from here <https://r-pkgs.org/release.html>.

My development computer is running Ubuntu 24.04.

## Test 1: R CMD check results

0 errors \| 0 warnings \| 0 notes

-   This is a new release.

## Test 2: Spell Check

`devtools::spell_check()` returns no legitimate spelling errors

## Test 3: Goodpractice

I run `goodpractice::gp()` succesfully with the following message

♥ Mmh! Splendid package! Keep up the world-class work!

## Test 4: Check

On running: `devtools::check(remote = TRUE, manual = TRUE)`

I receive the following notes:

```         
❯   Maintainer: ‘David Hammond <anotherdavidhammond@gmail.com>’
  
  New submission
```

This is ignored as it is a new submission.

❯ checking HTML version of manual ... NOTE Skipping checking HTML validation: no command 'tidy' found

This note has been suggested not to be an issue. <https://stackoverflow.com/questions/74857062/rhub-cran-check-keeps-giving-html-note-on-fedora-test-no-command-tidy-found>

## Test 5: Windows

On running:

`devtools::check_win_devel()`
