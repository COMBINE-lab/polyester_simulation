# Locations of starting files

* `isoforms.results.out`
* `reference.fa`
* `reference.gtf`
* `reference.sqlite`
* `fitpar_all.rda`

---

# What to run

* make subdirectory `out` and within this, make `out_1` through `out_8`
  (this is to deal with polyester not having built-in parallel)
* install the packages in `R_pkgs.md`
* install [Bioc devel branch polyester](http://bioconductor.org/packages/3.4/bioc/src/contrib/polyester_1.9.4.tar.gz)
  by downloading tarball and `R CMD INSTALL polyester_1.9.4.tar.gz`
* Run `simulate_expression.R`: this is fast, I'd run it interactively or `source()`
* Run `simulate_reads.R` in parallel using `Rscript` (see below)
* ~~Optional: run `shuffle_fasta.R`~~ This is now taken care of through the "do_shuffle.sh" script (Note: you'll need [pigz](zlib.net/pigz/) to run this)

---

How to run `simulate_reads.R` in parallel. This requires on my cluster
50 GB and takes 1:45 (hr:min).

```
seq 8 | parallel -j 8 Rscript --vanilla simulate_reads.R {}
```

