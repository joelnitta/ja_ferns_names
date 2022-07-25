# ja_ferns_names

Project to standardize names of Japanese ferns from GBIF using the [taxastand](https://github.com/joelnitta/taxastand) R package.

## Installing R packages

`renv` is used to maintain package versions. Packages for this project can be installed with `renv::restore()`.

## Datafiles

Currently, one data file needs to be downloaded manually. It is the "2-degree mesh map" (`mesh2.zip`), available from http://gis.biodic.go.jp/ (in Japanese). This should be saved to `_targets/user/`.

## Docker

This code requires [docker](https://www.docker.com/) to be installed.

## Running the example

After installing packages, run `targets::tar_make()`. The analysis will run and a final report will be produced as `index.html`.

The rendered report can be viewed at https://joelnitta.github.io/ja_ferns_names/