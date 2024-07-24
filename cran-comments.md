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

## Test 6: Mac

On running:

`devtools::check_mac_release()`

I receive no errors.

## Test 7: Rhub

I run `rhub::rhub_setup` and `rhub::rhub_doctor()`

After this all `rhub::rhub_check()` are successful except for:

-   `intel` Issue Error in dyn.load(file, DLLpath = DLLpath, ...) : unable to load shared object '/github/home/R/x86_64-pc-linux-gnu-library/4.5/classInt/libs/classInt.so':

    -   Ignoring as this seems to be a container issue <https://stackoverflow.com/questions/38943764/r-error-in-dyn-loadfile-dllpath-dllpath>

-   `rchk` Error: bcheck output file does not exist

    -   Ignoring again as this seems a container issue.

        libgfortran.so.5: cannot open shared object file: No such file or directory
