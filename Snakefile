import os

# The following should be available in PATH
# bowtie2 and bowtie2-build, kallisto, express, salmon and samtools

salmon='salmon'
kal='kallisto'
samples = [1, 2, 3, 4, 5, 6, 7, 8]

rule all:
    input: \
	expand("out/out_{sample}/sample_01/express/results.xprs", sample=samples), expand("out/out_{sample}/sample_02/express/results.xprs", sample=samples), \
	expand("out/out_{sample}/sample_01/salmon/quant.sf", sample=samples), expand("out/out_{sample}/sample_02/salmon/quant.sf", sample=samples), \
	expand("out/out_{sample}/sample_01/salmon_align/quant.sf", sample=samples), expand("out/out_{sample}/sample_02/salmon_align/quant.sf", sample=samples), \
	expand("out/out_{sample}/sample_01/kallisto/abundance.tsv", sample=samples), expand("out/out_{sample}/sample_02/kallisto/abundance.tsv", sample=samples) 

rule build_kallisto_index:
    input:
        "reference.fa"
    output:
        "indices/kallisto"
    message:
        "Building kallisto index"
    run:
        shell("mkdir -p indices")
        cmd = "{} index -i {} {}".format(kal, output, input)
        shell(cmd)

rule build_salmon_index:
    input:
        "reference.fa"
    output:
        "indices/salmon"
    message:
        "Building salmon index"
    run:
        shell("mkdir -p indices")
        cmd = "{} index -i {} -t {}".format(salmon, output, input)
        shell(cmd)


rule build_bowtie2_index:
    input:
        "reference.fa"
    output:
        "indices/bowtie2.1.bt2"
    message:
        "Building bowtie2 index"
    run:
        cmd = "{} --offrate 1 {} {}".format("bowtie2-build", input, output)
        shell(cmd)


rule bowtie2_alignments:
    input:
        expand("out/out_{sample}/sample_01/bowtie2/aln.bam", sample=samples),
        expand("out/out_{sample}/sample_02/bowtie2/aln.bam", sample=samples)

rule salmon_quants:
    input:
        expand("out/out_{sample}/sample_01/salmon/quant.sf", sample=samples),
        expand("out/out_{sample}/sample_02/salmon/quant.sf", sample=samples)

rule salmon_align_quants:
    input:
        expand("out/out_{sample}/sample_01/salmon_align/quant.sf", sample=samples),
        expand("out/out_{sample}/sample_02/salmon_align/quant.sf", sample=samples),

rule kallisto_quants:
    input:
        expand("out/out_{sample}/sample_01/kallisto/abundance.tsv", sample=samples),
        expand("out/out_{sample}/sample_02/kallisto/abundance.tsv", sample=samples)

rule express_quants:
    input:
        expand("out/out_{sample}/sample_01/express/results.xprs", sample=samples),
        expand("out/out_{sample}/sample_02/express/results.xprs", sample=samples)
          
rule bowtie2_align_sample:
    input:
        lr="out/out_{samp}/sample_{subsamp}_1_shuffled.fa.gz",
        rr="out/out_{samp}/sample_{subsamp}_2_shuffled.fa.gz",
        index="indices/bowtie2.1.bt2"
    output:
        "out/out_{samp}/sample_{subsamp}/bowtie2/aln.bam"
    message:
        "Running bowtie2 on {wildcards.samp} {wildcards.subsamp}"
    threads:
        20
    run:
        outdir = os.path.sep.join(output[0].split(os.path.sep)[:-1])
        shell("mkdir -p {}".format(outdir))
        index = input.index[:-6]
        cmd="{} -x {} -p {} --no-discordant -k 200 -f -1 {} -2 {}  | samtools view -Sb - > {}".format(
            "bowtie2", index, threads, input.lr, input.rr, output[0])
        shell(cmd)

rule express_quant_sample:
    input:
        aln="out/out_{samp}/sample_{subsamp}/bowtie2/aln.bam",
        txps="reference.fa"
    output:
        "out/out_{samp}/sample_{subsamp}/express/results.xprs"
    message:
        "Running express on {wildcards.samp} {wildcards.subsamp}"
    threads:
        3
    run:
        outdir = os.path.sep.join(output[0].split(os.path.sep)[:-1])
        shell("mkdir -p {}".format(outdir))
        cmd="express {} {} -o {}".format(input.txps, input.aln, outdir)
        shell(cmd)


rule salmon_align_quant_sample:
    input:
        aln="out/out_{samp}/sample_{subsamp}/bowtie2/aln.bam",
        txps="reference.fa"
    output:
        "out/out_{samp}/sample_{subsamp}/salmon_align/quant.sf"
    message:
        "Running salmon (align) on {wildcards.samp} {wildcards.subsamp}"
    threads:
        8
    run:
        outdir = os.path.sep.join(output[0].split(os.path.sep)[:-1])
        shell("mkdir -p {}".format(outdir))
        cmd="{} quant -t {} -l IU -a {} --gcBias --seqBias --noBiasLengthThreshold --useErrorModel -o {} -p {}".format(
            salmon, input.txps, input.aln, outdir, threads)
        shell(cmd)

rule kallisto_quant_sample:
    input:
        lr="out/out_{samp}/sample_{subsamp}_1_shuffled.fa.gz",
        rr="out/out_{samp}/sample_{subsamp}_2_shuffled.fa.gz",
        index="indices/kallisto"
    output:
        "out/out_{samp}/sample_{subsamp}/kallisto/abundance.tsv"
    message:
        "Running kallisto on {wildcards.samp} {wildcards.subsamp}"
    threads:
        8
    run:
        outdir = os.path.sep.join(output[0].split(os.path.sep)[:-1])
        shell("mkdir -p {}".format(outdir))
        cmd="{} quant -i {} -o {} -t {} --bias <(gunzip -c {}) <(gunzip -c {})".format(
            kal, input.index, outdir, threads, input.lr, input.rr)
        shell(cmd)

rule salmon_quant_sample:
    input:
        lr="out/out_{samp}/sample_{subsamp}_1_shuffled.fa.gz",
        rr="out/out_{samp}/sample_{subsamp}_2_shuffled.fa.gz",
        index="indices/salmon"
    output:
        "out/out_{samp}/sample_{subsamp}/salmon/quant.sf"
    message:
        "Running salmon on {wildcards.samp} {wildcards.subsamp}"
    threads:
        8
    run:
        outdir = os.path.sep.join(output[0].split(os.path.sep)[:-1])
        shell("mkdir -p {}".format(outdir))
        cmd="{} quant -i {} -l IU -1 <(gunzip -c {}) -2 <(gunzip -c {}) --gcBias --seqBias --noBiasLengthThreshold -o {} -p {}".format(
            salmon, input.index, input.lr, input.rr, outdir, threads)
        shell(cmd)
