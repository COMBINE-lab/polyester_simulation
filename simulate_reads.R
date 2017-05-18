args <- commandArgs(trailingOnly = TRUE)
i <- as.numeric(args[1])

#from: http://stackoverflow.com/questions/27673000/rscript-there-is-no-package-called
#library.path <- cat(.libPaths())
#library(polyester, lib.loc = library.path)
library(polyester)
stopifnot(packageVersion("polyester") >= "1.9.4")

load("simulate.rda")
se <- simulate_experiment("transcripts.fa",
                          reads_per_transcript=sim_counts,
                          num_reps=c(1,1),
                          fold_changes=fold_changes,
                          outdir=paste0("out/out_",i),
                          fraglen=200,
                          fragsd=25,
                          frag_GC_bias=frag_GC_bias[,c(i,i + 15)],
                          seed=i)

print("shuffling and compressing files")
out_dir = paste0("out/out_",i)
out_left_1 <- paste0(out_dir, "/", "sample_01_1.fasta")
out_right_1 <- paste0(out_dir, "/", "sample_01_2.fasta")
system2("./do_shuffle.sh", c("-l", out_left_1, "-r", out_right_1, "-d", "-z"))

out_left_2 <- paste0(out_dir, "/", "sample_02_1.fasta")
out_right_2 <- paste0(out_dir, "/", "sample_02_2.fasta")
system2("./do_shuffle.sh", c("-l", out_left_2, "-r", out_right_2, "-d", "-z"))

