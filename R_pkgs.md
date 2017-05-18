# from CRAN

splines
logspline
readr
RColorBrewer
knitr
digest

# from Bioconductor

GenomicRanges
Biostrings
Rsamtools
limma
tximport

---

CRAN pkgs can be installed with `install.packages`

Bioconductor and CRAN pkgs can be installed with:

```
source("http://bioconductor.org")
biocLite() # only necessary first time
biocLite(c("foo","bar"))
```
