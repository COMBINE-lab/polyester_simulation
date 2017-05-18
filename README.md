# To fetch the source files 

The files used as input for the simulation exceed the 
size allowed in a Github repository.  They can be fetched 
using the `fetch_from_zenodo.sh` script.  To fetch the files, 
exectute the command:

```
bash fetch_from_zenodo.sh -c simsrc
```

Note, the full set of simulated reads is also hosted on Zenodo, and
those can be fetched with the command:

```
bash fetch_from_zenodo.sh -c simres
```

These files total ~55G, so downloading them might take a while.
You can fetch both the source and result files for the simulation
with:

```
bash fetch_from_zenodo.sh -c both 
```

---

# What to run

To generate the simulated reads from the source data, you'll need to execute the following steps:

* within the `out` subdirectory, make `out_1` through `out_8`
  (this is to deal with polyester not having built-in parallel)
* install the packages in `R_pkgs.md`
* install [Bioc devel branch polyester](http://bioconductor.org/packages/3.4/bioc/src/contrib/polyester_1.9.4.tar.gz)
  by downloading tarball and `R CMD INSTALL polyester_1.9.4.tar.gz`
* Run `simulate_expression.R`: this is fast, I'd run it interactively or `source()`
* Run `simulate_reads.R` in parallel using `Rscript` (see below)

---

How to run `simulate_reads.R` in parallel. This requires on my cluster
50 GB and takes 1:45 (hr:min).

```
seq 8 | parallel -j 8 Rscript --vanilla simulate_reads.R {}
```

