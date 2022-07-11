# ja_ferns_names

Project to standardize names of Japanese ferns from GBIF using the taxastand R package.

## Running in docker

A docker image is provided to run the code. Launch it like this:

```
cd ja_ferns_names # Navigate to the folder containing taxastand first
docker run --rm -dt -v ${PWD}:/home/rstudio/ja_ferns_names -p 8787:8787 -e DISABLE_AUTH=true joelnitta/ja_ferns_names:latest
```
