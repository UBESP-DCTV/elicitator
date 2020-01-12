* Fixed button order (by row instead of by column)
* Added pooled plot
* Changed SQL query in `retrieve_opinons()` to a full direct SQL call
  to reduce computational and data loading.

# elicitator 0.1.0

* Update UI to show Admin tab if pertinent.
* Defined `retrieve_opinions` to retrieve all the last elicitated
  values each expert. The function can be executed buy admin only.
* Move testing computation inside tests to permit to skip them
* reshaping the app in multiple files
* Save/restore session implemented 
* Defined `last_stored_vals` to retrieve the last(s) expert elicitated
  values
* Defined `store_expert_vals()` to store the expert elicitated values
* Defined `get_usr()` to extract information from the user providing
  their credentials.

# elicitator (development version)

* Fix `.travis.yml` (typos in spaces)
* Added logo
* Update `.Rbuildignore`

* Added basic development support:

  - git + GitHub +
    * `.github/CODE_OF_CONDUCT.md`
    * `.github/CONTRIBUTING.md`
    * `.github/ISSUE_TEMPLATE.md`
    * `.github/SUPPORT.md`

  - appVeyor + Travis + codecov;

  - gpl3 license;

  - testthat + roxygen2 + spellcheck;

  - `` magrittr::`%>%` ``;

  - `README.Rmd` + `README.md`;

  - `cran0comments.md`.


# elicitator 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
