#!/bin/bash

getsrc () 
{ 
echo "fetching source files"
if [ -e sim_source_files.tar.gz ]; then
	rm sim_source_files.tar.gz
fi
wget https://zenodo.org/record/580815/files/sim_source_files.tar.gz
tar xzvf sim_source_files.tar.gz
}

getres () 
{ 
echo "fetching result files"
if [ -e out1_4.tar.gz ]; then
	rm out1_4.tar.gz 
fi
if [ -e out5_8.tar.gz ]; then
	rm out5_8.tar.gz 
fi
echo "downloading samples 1-4"
wget https://zenodo.org/record/580776/files/out1_4.tar.gz
echo -e "done\ndownloading samples 1-4"
wget https://zenodo.org/record/580774/files/out5_8.tar.gz
echo -e "done\nextracting samples"
tar xzvf out1_4.tar.gz
tar xzvf out5_8.tar.gz
}



OPTIND=1
content=

while getopts "h?c:" opt; do 
        case "$opt" in
	c)
       		content="$OPTARG"
		shift
		;;
	h|\?)
		echo "Fetch data from zenodo : options are {simsrc|simres|both}"
		echo "     simsrc : just the source files required to generate simulated data"
		echo "     simres : the actual simulated reads"
		echo "     both   : both the source and result files"
		exit 0
		;;
	esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

case $content in
    simsrc)
	getsrc
	;;
    simres)
	cd out
	getres	
	cd ..
	;;
    both)
	getsrc
	cd out
	getres
	cd ..
	echo "both"
	;;
esac
		
